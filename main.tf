terraform {
  required_providers {
    checkpoint = {
      source  = "checkpointsw/checkpoint"
      //version = "~> 1.6.0"
    }
  }
}

# Configure the Check Point Provider
provider "checkpoint" {
  server   = var.cp-mgmt-server
  username = var.cp-mgmt-username
  password = var.cp-mgmt-password
  context  = var.cp-mgmt-context
  session_name = "terraform_session"
}

data "checkpoint_management_data_access_rule" "data_access_rule"{
  name = "Cleanup rule"
  layer = "Network"
}

output "instance_ip_addr" {
  value = data.checkpoint_management_data_access_rule.data_access_rule.action
}


resource "checkpoint_management_access_rule" "add-rule" {
  layer = "Network"
  position = {above = data.checkpoint_management_data_access_rule.data_access_rule.name}
  name = var.cp-name
  action = var.cp-action
  //action_settings = {
  //  enable_identity_captive_portal = true
  //
  source = [var.cp-source-networks]
  enabled = true
  destination = [var.cp-destination-networks]
  //destination_negate = true
  service = [var.cp-service]


  track = {
    type = "Log"
    accounting = false
    alert = "SNMP"
    enable_firewall_session = false
    per_connection = true
    per_session = false
  }
}


resource "checkpoint_management_publish" "publish" { 
  depends_on = [
    checkpoint_management_access_rule.add-rule
  ]
}
resource "checkpoint_management_logout" "logout" {
  depends_on = [
    checkpoint_management_publish.publish
 ]
}
