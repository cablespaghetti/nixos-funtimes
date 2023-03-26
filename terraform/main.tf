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
    volume_type = "b_ssd"
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
      environment.systemPackages = with pkgs; [ neofetch vim ];
      users.users.${var.username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [
          "${var.ssh_key}"
        ];
      };
    }
runcmd:
  - rm /root/.ssh/authorized_keys
  - rm /home/ubuntu/.ssh/authorized_keys
  - curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | NIXOS_IMPORT=./host.nix NIX_CHANNEL=nixos-22.11 bash 2>&1 | tee /tmp/infect.log
EOF
  }
}

