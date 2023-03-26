resource "scaleway_instance_security_group" "web" {
  project_id              = var.project_id
  name                    = "nixos-web"
  inbound_default_policy  = "drop"
  outbound_default_policy = "accept"

  inbound_rule {
    action   = "accept"
    port     = "22"
    ip_range = "::/0"
  }
  inbound_rule {
    action   = "accept"
    port     = "22"
    ip_range = "0.0.0.0/0"
  }
}
