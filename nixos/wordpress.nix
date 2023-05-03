{pkgs, ...}:
{
  services.wordpress = {
    webserver = "caddy";
    sites."nixos-web-1" = {
      package = pkgs.wordpress6_1;  
      plugins = with pkgs.wordpressPackages.plugins; [
        disable-xml-rpc
        simple-login-captcha
      ];
      extraConfig = ''
          // Enable the plugin 
          if ( !defined('ABSPATH') )
            define('ABSPATH', dirname(__FILE__) . '/');
          require_once(ABSPATH . 'wp-settings.php');
          require_once ABSPATH . 'wp-admin/includes/plugin.php';
          activate_plugin( 'disable-xml-rpc/disable-xml-rpc.php' );
          activate_plugin( 'simple-login-captcha/simple-login-captcha.php' );
      ''; 
    };
  };
}
