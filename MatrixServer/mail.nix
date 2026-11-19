{ config, lib, pkgs, ... }:

let
  domain = "xiaoxi654.dn42";
  mailHost = "mail.${domain}";
  account = "xiaoxi";
  address = "${account}@${domain}";
  certificateDirectory = "/var/lib/acme/${mailHost}";
  listenAddresses = [
    "10.127.101.51"
    "fdec:4f96:8be1:102:24d6:dda2:60d5:158c"
  ];
  passwordFile = config.sops.secrets.mail_xiaoxi_passwd.path;

  virtualMailboxMap = pkgs.writeText "postfix-virtual-mailbox" ''
    ${address} OK
  '';
  senderLoginMap = pkgs.writeText "postfix-sender-login" ''
    ${address} ${address}
  '';
  recipientAccessMap = pkgs.writeText "postfix-recipient-access" ''
    /@([^.@ ]+\.)*dn42$/ OK
    /./ REJECT 5.7.1 Only DN42 recipients are allowed
  '';
  transportMap = pkgs.writeText "postfix-transport" ''
    /@xiaoxi654\.dn42$/ lmtp:unix:/run/dovecot2/lmtp
    /@([^.@ ]+\.)*dn42$/ smtp:
  '';

  dkimSelector = "mail";
  dkimMilterSocket = "inet:8891@127.0.0.1";
  dkimMilterTarget = "inet:127.0.0.1:8891";
  dkimKeyPath = "/var/lib/opendkim/keys";
  dkimPrivateKey = config.sops.secrets.mail_dkim_private_key.path;
  # DKIM public key, published as TXT at mail._domainkey.xiaoxi654.dn42 in the dn42 zone.
  # The opendkim preStart below verifies the deployed private key against this value.
  dkimPublicKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3ILBib0Fx9Ag+vMwMmmzNhQC3DXULy4s0A8/4dRasVnf07c+R7Z1J8HKv97n6JifCIcJ00w+lHgFJV60/v1ylhkSiRJ4cFbac5qWc7SdZ0u8gT4o74iIhd/WDuXMU3e3INp/+WF2p3fzgIVSldbR9PWkK+37J0vnbPLj61edJlwO/A4wlEKTAcJzjmfqV0Aw7kwmqLp++a/Dxfi8Gpg74ww/CORJLl+2pOrCJCS1Wf2GsvQw7XKiCIV97ENuUFPXtYLhiwjypuSAKbpbOl+Po3dhIJbMs++Vxp0IZOvHFFYTYCtxQM2t0izH53i8gVEFSQ99a4iitl9MQIJo0bz8/wIDAQAB";
in
{
  sops.secrets.mail_xiaoxi_passwd = {
    sopsFile = ./secrets/mail.yaml;
    owner = "dovecot2";
    group = "dovecot2";
    mode = "0400";
    restartUnits = [ "dovecot.service" "postfix.service" ];
  };

  sops.secrets.mail_dkim_private_key = {
    sopsFile = ./secrets/mail.yaml;
    owner = "opendkim";
    group = "opendkim";
    mode = "0400";
    restartUnits = [ "opendkim.service" ];
  };

  security.acme.acceptTerms = true;

  security.acme.certs.${mailHost} = {
    group = "postfix";
    listenHTTP = "127.0.0.1:8402";
    reloadServices = [ "postfix.service" "dovecot.service" ];
    server = "https://acme.burble.dn42/v1/dn42/acme/directory";
  };

  systemd.services."acme-order-renew-${mailHost}" = {
    wants = [ "caddy.service" ];
    after = [ "caddy.service" ];
  };

  services.postfix = {
    enable = true;
    enableSubmission = false;
    enableSubmissions = true;
    postmasterAlias = address;
    rootAlias = address;
    virtual = ''
      postmaster@${domain} ${address}
    '';
    mapFiles = {
      virtual_mailbox = virtualMailboxMap;
      sender_login = senderLoginMap;
      recipient_access = recipientAccessMap;
      transport = transportMap;
    };

    submissionsOptions = {
      smtpd_sasl_auth_enable = "yes";
      smtpd_sasl_type = "dovecot";
      smtpd_sasl_path = "/run/dovecot2/auth-postfix";
      smtpd_tls_security_level = "encrypt";
      smtpd_tls_auth_only = "yes";
      smtpd_client_restrictions = "permit_sasl_authenticated,reject";
      smtpd_sender_restrictions = "reject_sender_login_mismatch";
      smtpd_recipient_restrictions = "dn42_only";
      smtpd_relay_restrictions = "dn42_only";
    };

    settings.main = {
      myhostname = mailHost;
      mydomain = domain;
      myorigin = domain;
      inet_interfaces = listenAddresses;
      inet_protocols = "ipv4, ipv6";
      mynetworks = [
        "127.0.0.0/8"
        "[::1]/128"
      ];
      smtp_bind_address = "10.127.101.51";
      smtp_bind_address6 = "fdec:4f96:8be1:102:24d6:dda2:60d5:158c";
      smtp_helo_name = mailHost;

      virtual_mailbox_domains = [ domain ];
      virtual_mailbox_maps = [ "hash:/etc/postfix/virtual_mailbox" ];
      virtual_transport = "lmtp:unix:/run/dovecot2/lmtp";
      unknown_virtual_mailbox_reject_code = 550;

      transport_maps = [ "regexp:/etc/postfix/transport" ];
      default_transport = "error:5.7.1 Only DN42 recipients are allowed";

      smtpd_sasl_auth_enable = false;
      smtpd_sasl_type = "dovecot";
      smtpd_sasl_path = "/run/dovecot2/auth-postfix";
      smtpd_sasl_security_options = "noanonymous";
      smtpd_sasl_local_domain = domain;
      smtpd_sender_login_maps = [ "hash:/etc/postfix/sender_login" ];

      # DKIM signing via the opendkim milter
      smtpd_milters = dkimMilterTarget;
      non_smtpd_milters = dkimMilterTarget;
      milter_default_action = "accept";
      milter_protocol = "6";

      smtpd_tls_chain_files = [
        "${certificateDirectory}/key.pem"
        "${certificateDirectory}/fullchain.pem"
      ];
      smtpd_tls_security_level = "may";
      smtpd_tls_auth_only = true;
      smtpd_tls_protocols = ">=TLSv1.2";
      smtpd_tls_mandatory_protocols = ">=TLSv1.2";
      smtp_tls_security_level = "may";
      smtp_tls_CAfile = config.security.pki.caBundle;

      disable_vrfy_command = true;
      smtpd_helo_required = true;
      message_size_limit = 26214400;
      smtpd_recipient_restrictions = "permit_mynetworks,reject_unauth_destination";
      smtpd_relay_restrictions = "permit_mynetworks,reject_unauth_destination";
      smtpd_restriction_classes = "dn42_only";
      dn42_only = "check_recipient_access regexp:/etc/postfix/recipient_access, reject";
    };
  };

  services.opendkim = {
    enable = true;
    domains = "csl:${domain}";
    selector = dkimSelector;
    keyPath = dkimKeyPath;
    # inet socket instead of the module default unix socket: the module's
    # UMask=0077 makes the unix socket unreadable for postfix
    socket = dkimMilterSocket;
  };

  # Install the DKIM private key (base64-wrapped PEM from sops) before the
  # module's auto-generation check runs, and verify it matches the public key
  # committed in mail.nix.
  systemd.services.opendkim.preStart = lib.mkBefore ''
    umask 0077
    ${pkgs.coreutils}/bin/base64 -d ${dkimPrivateKey} > ${dkimKeyPath}/${dkimSelector}.private
    actual=$(${pkgs.openssl}/bin/openssl rsa -in ${dkimKeyPath}/${dkimSelector}.private -pubout -outform DER 2>/dev/null | ${pkgs.coreutils}/bin/base64 -w0)
    if [ "$actual" != '${dkimPublicKey}' ]; then
      echo "mail: sops secret mail_dkim_private_key does not match dkimPublicKey in mail.nix" >&2
      exit 1
    fi
  '';

  services.dovecot2 = {
    enable = true;
    package = pkgs.dovecot;
    settings = {
      dovecot_config_version = "2.4.5";
      dovecot_storage_version = "2.4.5";
      protocols = {
        imap = true;
        lmtp = true;
      };
      listen = listenAddresses;
      ssl = true;
      ssl_server_cert_file = "${certificateDirectory}/fullchain.pem";
      ssl_server_key_file = "${certificateDirectory}/key.pem";
      ssl_min_protocol = "TLSv1.2";
      auth_mechanisms = [
        "plain"
        "login"
      ];
      auth_allow_cleartext = true;
      auth_username_format = "%{user | lower}";
      mail_driver = "maildir";
      mail_home = "/var/lib/vmail/%{user | domain}/%{user | username}";
      mail_path = "~/Maildir";
      mail_uid = "vmail";
      mail_gid = "vmail";
      first_valid_uid = 1;
      "namespace inbox" = {
        inbox = true;
        separator = "/";
      };
      "passdb passwd-file" = {
        passwd_file_path = passwordFile;
      };
      service = [
        {
          _section.name = "imap-login";
          "inet_listener imap".port = 0;
          "inet_listener imaps" = {
            port = 993;
            ssl = true;
          };
        }
        {
          _section.name = "lmtp";
          "unix_listener lmtp" = {
            mode = "0660";
            user = "postfix";
            group = "postfix";
          };
        }
        {
          _section.name = "auth";
          "unix_listener auth-postfix" = {
            mode = "0660";
            user = "postfix";
            group = "postfix";
          };
        }
      ];
    };
  };

  systemd.services.dovecot = {
    wants = [ "acme-${mailHost}.service" ];
    after = [ "acme-${mailHost}.service" ];
    preStart = lib.mkBefore ''
      if ! ${pkgs.gnugrep}/bin/grep -q '^${account}@${domain}:{ARGON2ID}' ${lib.escapeShellArg passwordFile}; then
        echo "mail: replace the placeholder in MatrixServer/secrets/mail.yaml with an Argon2id hash" >&2
        exit 1
      fi
    '';
  };

  systemd.services.postfix = {
    wants = [ "acme-${mailHost}.service" "opendkim.service" ];
    requires = [ "dovecot.service" ];
    after = [
      "acme-${mailHost}.service"
      "dovecot.service"
      "opendkim.service"
    ];
  };

  systemd.services.postfix-setup.postStart = lib.mkAfter ''
    systemctl --no-block try-reload-or-restart postfix.service
  '';

  systemd.tmpfiles.rules = [
    "d /var/lib/vmail 0700 vmail vmail - -"
    "d /var/lib/vmail/${domain} 0700 vmail vmail - -"
  ];

  networking.firewall.allowedTCPPorts = [
    25
    465
    993
  ];
}
