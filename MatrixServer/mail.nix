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
in
{
  sops.secrets.mail_xiaoxi_passwd = {
    sopsFile = ./secrets/mail.yaml;
    owner = "dovecot2";
    group = "dovecot2";
    mode = "0400";
    restartUnits = [ "dovecot.service" "postfix.service" ];
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
    wants = [ "acme-${mailHost}.service" ];
    requires = [ "dovecot.service" ];
    after = [
      "acme-${mailHost}.service"
      "dovecot.service"
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
