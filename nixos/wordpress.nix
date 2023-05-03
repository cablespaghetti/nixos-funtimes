{pkgs, ...}: let
  language-en = pkgs.stdenv.mkDerivation {
    name = "language-en";
    src = pkgs.fetchurl {
      url = "https://en.wordpress.org/wordpress-${pkgs.wordpress6_1.version}-en_GB.tar.gz";
      name = "wordpress-${pkgs.wordpress6_1.version}-en_GB.tar.gz";
      sha256 = "5cfae3a5a40526915d5ba0ea7dee7e2d89df0d3c50647c6b42d5ce087ff783d3";
    };
    installPhase = "mkdir -p $out; cp -r ./wp-content/languages/* $out/";
  };
in {
  services.wordpress = {
    webserver = "caddy";
    sites."nixos-web-1" = {
      package = pkgs.wordpress6_1;
      plugins = {
        inherit (pkgs.wordpressPackages.plugins)
          disable-xml-rpc
          simple-login-captcha;
      };
      themes = {
        inherit (pkgs.wordpressPackages.themes)
          twentytwentyone;
      };
      languages = [ language-en ];
      settings = {
        WPLANG = "en_GB";
        WP_DEFAULT_THEME = "twentytwentyone";
      };
    };
  };
}
