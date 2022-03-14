#!/bin/sh
# Setup CSE config file
mkdir -p /home/vmware
cat > /home/vmware/config-not-encrypted.conf << EOF
mqtt:
  verify_ssl: false
 
vcd:
  host: vcd.vmwire.com
  log: true
  password: Vmware1!
  port: 443
  username: administrator
  verify: true
 
vcs:
- name: vcenter.vmwire.com
  password: Vmware1!
  username: administrator@vsphere.local
  verify: true
 
service:
  enforce_authorization: false
  legacy_mode: false
  log_wire: false
  no_vc_communication_mode: false
  processors: 15
  telemetry:
    enable: true
 
broker:
  catalog: cse-catalog
  ip_allocation_mode: pool
  network: default-organization-network
  org: cse
  remote_template_cookbook_url: https://raw.githubusercontent.com/vmware/container-service-extension-templates/master/template_v2.yaml
  storage_profile: 'iscsi'
  vdc: cse-vdc
EOF
