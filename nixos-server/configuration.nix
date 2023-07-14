{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./host_ipv6.nix
    ./tailscale.nix
    ./wordpress.nix
  ];
  system.stateVersion = "22.11";
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "nixos-web-1";
  services.resolved.enable = true;
  services.openssh.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 22 443 ];
  };
}
