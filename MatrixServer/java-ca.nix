{ config, lib, pkgs, ... }:

let
  # Default CA bundle plus the DN42 root CA (PEM), used to generate the
  # Java trust store below.
  caBundle = pkgs.runCommand "dn42-ca-bundle.pem" { } ''
    cat ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt \
        ${pkgs.dn42-cacert}/etc/ssl/certs/dn42-ca.crt \
        > $out
  '';

  # Builds an unpassworded PKCS12 trust store (the format the JDK itself
  # uses for cacerts) containing every certificate in the bundle. Unlike
  # jre-generate-cacerts it stores the keystore without a password, so
  # the JVM can load it with its default empty trust store password.
  genCacerts = pkgs.writeText "GenCacerts.java" ''
    import java.io.ByteArrayInputStream;
    import java.io.FileOutputStream;
    import java.nio.charset.StandardCharsets;
    import java.nio.file.Files;
    import java.nio.file.Paths;
    import java.security.KeyStore;
    import java.security.cert.Certificate;
    import java.security.cert.CertificateFactory;
    import java.util.regex.Matcher;
    import java.util.regex.Pattern;

    public class GenCacerts {
      static final Pattern PEM = Pattern.compile(
          "-----BEGIN CERTIFICATE-----\\s*(?s:.+?)\\s*-----END CERTIFICATE-----");

      public static void main(String[] a) throws Exception {
        String bundle = new String(Files.readAllBytes(Paths.get(a[0])), StandardCharsets.UTF_8);
        CertificateFactory cf = CertificateFactory.getInstance("X.509");
        KeyStore ks = KeyStore.getInstance("PKCS12");
        ks.load(null, null);
        int i = 0;
        Matcher m = PEM.matcher(bundle);
        while (m.find()) {
          try {
            Certificate c = cf.generateCertificate(
                new ByteArrayInputStream(m.group().getBytes(StandardCharsets.US_ASCII)));
            ks.setCertificateEntry("cert" + (i++), c);
          } catch (Exception e) {
            // Skip malformed certificates, as jre-generate-cacerts does.
          }
        }
        if (i == 0) {
          throw new RuntimeException("no certificates parsed from bundle");
        }
        try (FileOutputStream out = new FileOutputStream(a[1])) {
          ks.store(out, null);
        }
      }
    }
  '';

  # Unpassworded PKCS12 trust store with the system CAs and the DN42 CA.
  javaCacerts = pkgs.runCommand "java-cacerts" { } ''
    mkdir -p $out
    ${pkgs.jdk25_headless}/bin/java ${genCacerts} ${caBundle} $out/cacerts
  '';

  # The JDK with the DN42 CA baked into its own lib/security/cacerts, so
  # every Java process using it trusts the DN42 CA without needing any
  # trust store environment variable.
  jdkWithDn42Ca = pkgs.runCommand "${pkgs.jdk25_headless.name}-dn42-ca" { } ''
    cp -r --reflink=auto ${pkgs.jdk25_headless} $out
    chmod -R u+w $out
    cp ${javaCacerts}/cacerts $out/lib/openjdk/lib/security/cacerts
    sed -i "s|${pkgs.jdk25_headless}|$out|g" $out/nix-support/setup-hook
  '';
in
{
  environment.systemPackages = [ jdkWithDn42Ca ];
}
