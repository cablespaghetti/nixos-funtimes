resource "scaleway_instance_ip" "web_public_ip" {
  project_id = var.project_id
}

resource "scaleway_instance_server" "web" {
  project_id  = var.project_id
  type        = var.instance_type
  image       = "ubuntu_focal"
  name        = "nixos-web-1"
  tags        = ["web", "nixos"]
  enable_ipv6 = true

  ip_id = scaleway_instance_ip.web_public_ip.id

  root_volume {
    size_in_gb  = var.volume_size
    volume_type = var.volume_type
  }

  security_group_id = scaleway_instance_security_group.web.id

  user_data = {
    cloud-init = <<EOF
#cloud-config
write_files:
- path: /etc/nixos/host.nix
  permissions: '0644'
  content: |
    {config, pkgs, ...}:
    {
      environment.systemPackages = with pkgs; [ neofetch vim tmux htop ];
      users.users.${var.username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [
          "${var.ssh_key}"
        ];
      };
      security.sudo.extraRules = [
        {
          groups = [ "wheel" ];
          commands = [ { command = "ALL"; options = [ "NOPASSWD" ]; } ];
        }
      ];
      networking = {
        defaultGateway6 = {
          address = "$${IPV6_GATEWAY}";
          interface = "ens2";
        };
        interfaces.ens2.ipv6 = {
          addresses = [{
            address = "$${IPV6_GATEWAY}1";
            prefixLength = 64;
          }];
        };
      };
    }
runcmd:
  # "Fix" nixos-infect choking on all the nonsense Scaleway injects into authorized_keys
  - rm /root/.ssh/authorized_keys
  - rm /home/ubuntu/.ssh/authorized_keys
  # Shenanigans to get IPV6 Config
  - export IPV6_GATEWAY=$(curl http://169.254.42.42/conf | grep IPV6_GATEWAY | cut -d'=' -f2)
  - envsubst '$IPV6_GATEWAY' < /etc/nixos/host.nix > /etc/nixos/host_ipv6.nix
  # Actually do some infecting...
  - curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | NIXOS_IMPORT=./host_ipv6.nix NIX_CHANNEL=nixos-22.11 bash 2>&1 | tee /tmp/infect.log
EOF
  }
}

