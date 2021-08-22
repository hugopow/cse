#!/bin/bash
# Script to install Container Service Extension 3.0.4

echo "Update Photon repositories"
cd /etc/yum.repos.d/
sed  -i 's/dl.bintray.com\/vmware/packages.vmware.com\/photon\/$releasever/g' photon.repo photon-updates.repo photon-extras.repo photon-debuginfo.repo
 
echo "Update Photon"
tdnf --assumeyes update
 
echo "Install dependencies"
tdnf --assumeyes install build-essential python3-devel python3-pip git sudo
 
echo "Prepare cse user and application directories"
mkdir -p /opt/vmware/cse
chmod 775 -R /opt
chmod 777 /
groupadd cse
useradd cse -g cse -m -p Vmware1! -d /opt/vmware/cse
chown cse:cse -R /opt
 
echo "Setup cse service account"
#su - cse
chown cse:cse -R /opt
sudo -u cse -i mkdir -p /opt/vmware/cse/.ssh
sudo -u cse -i cat >> /opt/vmware/cse/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAhcw67bz3xRjyhPLysMhUHJPhmatJkmPUdMUEZre+MeiDhC602jkRUNVu43Nk8iD/I07kLxdAdVPZNoZuWE7WBjmn13xf0Ki2hSH/47z3ObXrd8Vleq0CXa+qRnCeYM3FiKb4D5IfL4XkHW83qwp8PuX8FHJrXY8RacVaOWXrESCnl3cSC0tA3eVxWoJ1kwHxhSTfJ9xBtKyCqkoulqyqFYU2A1oMazaK9TYWKmtcYRn27CC1Jrwawt2zfbNsQbHx1jlDoIO6FLz8Dfkm0DToanw0GoHs2Q+uXJ8ve/oBs0VJZFYPquBmcyfny4WIh4L0lwzsiAVWJ6PvzF5HMuNcwQ== rsa-key-20210508
EOF

chown cse:cse -R /opt
sudo -u cse -i cat >> /opt/vmware/cse/.bash_profile << EOF
# For Container Service Extension
export CSE_TKG_M_ENABLED=True
export CSE_CONFIG=/opt/vmware/cse/config/config.yaml
export CSE_CONFIG_PASSWORD=Vmware1!
source /opt/vmware/cse/python/bin/activate
EOF
 
sudo -u cse -i echo "Install CSE in Python virtual environment"
sudo -u cse -i python3 -m venv /opt/vmware/cse/python
sudo -u cse -i source /opt/vmware/cse/python/bin/activate
sudo -u cse -i pip3 install git+https://github.com/vmware/container-service-extension.git@3.0.4

sudo -u cse -i cse version
 
sudo -u cse -i source /opt/vmware/cse/.bash_profile
 
sudo -u cse -i echo "Prepare vcd-cli"
sudo -u cse -i mkdir -p /opt/vmware/cse/.vcd-cli
sudo -u cse -i cat >  /opt/vmware/cse/.vcd-cli/profiles.yaml << EOF
extensions:
- container_service_extension.client.cse
EOF
 
sudo -u cse -i vcd cse version
 
sudo -u cse -i echo "Add my Let's Encrypt intermediate and root certs. Use your certificates issued by your CA to enable verify=true with CSE"
sudo -u cse -i cat >> /opt/vmware/cse/python/lib/python3.7/site-packages/certifi/cacert.pem << EOF
-----BEGIN CERTIFICATE-----
MIIFFjCCAv6gAwIBAgIRAJErCErPDBinU/bWLiWnX1owDQYJKoZIhvcNAQELBQAw
TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwHhcNMjAwOTA0MDAwMDAw
WhcNMjUwOTE1MTYwMDAwWjAyMQswCQYDVQQGEwJVUzEWMBQGA1UEChMNTGV0J3Mg
RW5jcnlwdDELMAkGA1UEAxMCUjMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
AoIBAQC7AhUozPaglNMPEuyNVZLD+ILxmaZ6QoinXSaqtSu5xUyxr45r+XXIo9cP
R5QUVTVXjJ6oojkZ9YI8QqlObvU7wy7bjcCwXPNZOOftz2nwWgsbvsCUJCWH+jdx
sxPnHKzhm+/b5DtFUkWWqcFTzjTIUu61ru2P3mBw4qVUq7ZtDpelQDRrK9O8Zutm
NHz6a4uPVymZ+DAXXbpyb/uBxa3Shlg9F8fnCbvxK/eG3MHacV3URuPMrSXBiLxg
Z3Vms/EY96Jc5lP/Ooi2R6X/ExjqmAl3P51T+c8B5fWmcBcUr2Ok/5mzk53cU6cG
/kiFHaFpriV1uxPMUgP17VGhi9sVAgMBAAGjggEIMIIBBDAOBgNVHQ8BAf8EBAMC
AYYwHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMBMBIGA1UdEwEB/wQIMAYB
Af8CAQAwHQYDVR0OBBYEFBQusxe3WFbLrlAJQOYfr52LFMLGMB8GA1UdIwQYMBaA
FHm0WeZ7tuXkAXOACIjIGlj26ZtuMDIGCCsGAQUFBwEBBCYwJDAiBggrBgEFBQcw
AoYWaHR0cDovL3gxLmkubGVuY3Iub3JnLzAnBgNVHR8EIDAeMBygGqAYhhZodHRw
Oi8veDEuYy5sZW5jci5vcmcvMCIGA1UdIAQbMBkwCAYGZ4EMAQIBMA0GCysGAQQB
gt8TAQEBMA0GCSqGSIb3DQEBCwUAA4ICAQCFyk5HPqP3hUSFvNVneLKYY611TR6W
PTNlclQtgaDqw+34IL9fzLdwALduO/ZelN7kIJ+m74uyA+eitRY8kc607TkC53wl
ikfmZW4/RvTZ8M6UK+5UzhK8jCdLuMGYL6KvzXGRSgi3yLgjewQtCPkIVz6D2QQz
CkcheAmCJ8MqyJu5zlzyZMjAvnnAT45tRAxekrsu94sQ4egdRCnbWSDtY7kh+BIm
lJNXoB1lBMEKIq4QDUOXoRgffuDghje1WrG9ML+Hbisq/yFOGwXD9RiX8F6sw6W4
avAuvDszue5L3sz85K+EC4Y/wFVDNvZo4TYXao6Z0f+lQKc0t8DQYzk1OXVu8rp2
yJMC6alLbBfODALZvYH7n7do1AZls4I9d1P4jnkDrQoxB3UqQ9hVl3LEKQ73xF1O
yK5GhDDX8oVfGKF5u+decIsH4YaTw7mP3GFxJSqv3+0lUFJoi5Lc5da149p90Ids
hCExroL1+7mryIkXPeFM5TgO9r0rvZaBFOvV2z0gp35Z0+L4WPlbuEjN/lxPFin+
HlUjr8gRsI3qfJOQFy/9rKIJR0Y/8Omwt/8oTWgy1mdeHmmjk7j1nYsvC9JSQ6Zv
MldlTTKB3zhThV1+XWYp6rjd5JW1zbVWEkLNxE7GJThEUG3szgBVGP7pSWTUTsqX
nLRbwHOoq7hHwg==
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIFYDCCBEigAwIBAgIQQAF3ITfU6UK47naqPGQKtzANBgkqhkiG9w0BAQsFADA/
MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
DkRTVCBSb290IENBIFgzMB4XDTIxMDEyMDE5MTQwM1oXDTI0MDkzMDE4MTQwM1ow
TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwggIiMA0GCSqGSIb3DQEB
AQUAA4ICDwAwggIKAoICAQCt6CRz9BQ385ueK1coHIe+3LffOJCMbjzmV6B493XC
ov71am72AE8o295ohmxEk7axY/0UEmu/H9LqMZshftEzPLpI9d1537O4/xLxIZpL
wYqGcWlKZmZsj348cL+tKSIG8+TA5oCu4kuPt5l+lAOf00eXfJlII1PoOK5PCm+D
LtFJV4yAdLbaL9A4jXsDcCEbdfIwPPqPrt3aY6vrFk/CjhFLfs8L6P+1dy70sntK
4EwSJQxwjQMpoOFTJOwT2e4ZvxCzSow/iaNhUd6shweU9GNx7C7ib1uYgeGJXDR5
bHbvO5BieebbpJovJsXQEOEO3tkQjhb7t/eo98flAgeYjzYIlefiN5YNNnWe+w5y
sR2bvAP5SQXYgd0FtCrWQemsAXaVCg/Y39W9Eh81LygXbNKYwagJZHduRze6zqxZ
Xmidf3LWicUGQSk+WT7dJvUkyRGnWqNMQB9GoZm1pzpRboY7nn1ypxIFeFntPlF4
FQsDj43QLwWyPntKHEtzBRL8xurgUBN8Q5N0s8p0544fAQjQMNRbcTa0B7rBMDBc
SLeCO5imfWCKoqMpgsy6vYMEG6KDA0Gh1gXxG8K28Kh8hjtGqEgqiNx2mna/H2ql
PRmP6zjzZN7IKw0KKP/32+IVQtQi0Cdd4Xn+GOdwiK1O5tmLOsbdJ1Fu/7xk9TND
TwIDAQABo4IBRjCCAUIwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAQYw
SwYIKwYBBQUHAQEEPzA9MDsGCCsGAQUFBzAChi9odHRwOi8vYXBwcy5pZGVudHJ1
c3QuY29tL3Jvb3RzL2RzdHJvb3RjYXgzLnA3YzAfBgNVHSMEGDAWgBTEp7Gkeyxx
+tvhS5B1/8QVYIWJEDBUBgNVHSAETTBLMAgGBmeBDAECATA/BgsrBgEEAYLfEwEB
ATAwMC4GCCsGAQUFBwIBFiJodHRwOi8vY3BzLnJvb3QteDEubGV0c2VuY3J5cHQu
b3JnMDwGA1UdHwQ1MDMwMaAvoC2GK2h0dHA6Ly9jcmwuaWRlbnRydXN0LmNvbS9E
U1RST09UQ0FYM0NSTC5jcmwwHQYDVR0OBBYEFHm0WeZ7tuXkAXOACIjIGlj26Ztu
MA0GCSqGSIb3DQEBCwUAA4IBAQAKcwBslm7/DlLQrt2M51oGrS+o44+/yQoDFVDC
5WxCu2+b9LRPwkSICHXM6webFGJueN7sJ7o5XPWioW5WlHAQU7G75K/QosMrAdSW
9MUgNTP52GE24HGNtLi1qoJFlcDyqSMo59ahy2cI2qBDLKobkx/J3vWraV0T9VuG
WCLKTVXkcGdtwlfFRjlBz4pYg1htmf5X6DYO8A4jqv2Il9DjXA6USbW1FzXSLr9O
he8Y4IWS6wY7bCkjCWDcRQJMEhg76fsO3txE+FiYruq9RUWhiF1myv4Q6W+CyBFC
Dfvp7OOGAN6dEOM4+qR9sdjoSYKEBpsr6GtPAQw4dy753ec5
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIDSjCCAjKgAwIBAgIQRK+wgNajJ7qJMDmGLvhAazANBgkqhkiG9w0BAQUFADA/
MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
DkRTVCBSb290IENBIFgzMB4XDTAwMDkzMDIxMTIxOVoXDTIxMDkzMDE0MDExNVow
PzEkMCIGA1UEChMbRGlnaXRhbCBTaWduYXR1cmUgVHJ1c3QgQ28uMRcwFQYDVQQD
Ew5EU1QgUm9vdCBDQSBYMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
AN+v6ZdQCINXtMxiZfaQguzH0yxrMMpb7NnDfcdAwRgUi+DoM3ZJKuM/IUmTrE4O
rz5Iy2Xu/NMhD2XSKtkyj4zl93ewEnu1lcCJo6m67XMuegwGMoOifooUMM0RoOEq
OLl5CjH9UL2AZd+3UWODyOKIYepLYYHsUmu5ouJLGiifSKOeDNoJjj4XLh7dIN9b
xiqKqy69cK3FCxolkHRyxXtqqzTWMIn/5WgTe1QLyNau7Fqckh49ZLOMxt+/yUFw
7BZy1SbsOFU5Q9D8/RhcQPGX69Wam40dutolucbY38EVAjqr2m7xPi71XAicPNaD
aeQQmxkqtilX4+U9m5/wAl0CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNV
HQ8BAf8EBAMCAQYwHQYDVR0OBBYEFMSnsaR7LHH62+FLkHX/xBVghYkQMA0GCSqG
SIb3DQEBBQUAA4IBAQCjGiybFwBcqR7uKGY3Or+Dxz9LwwmglSBd49lZRNI+DT69
ikugdB/OEIKcdBodfpga3csTS7MgROSR6cz8faXbauX+5v3gTt23ADq1cEmv8uXr
AvHRAosZy5Q6XkjEGB5YGV8eAlrwDPGxrancWYaLbumR9YbK+rlmM6pZW87ipxZz
R8srzJmwN0jP41ZL9c8PDHIyh8bwRLtTcm1D9SZImlJnt1ir/md2cXjbDaJWFBM5
JDGFoqgCWjBH4d1QB7wCCZAA62RjYJsWvIjJEubSfZGL+T0yjWW06XyxV3bqxbYo
Ob8VZRzI9neWagqNdwvYkQsEjgfbKbYK7p2CNTUQ
-----END CERTIFICATE-----
EOF
 
sudo -u cse -i echo "Create cse service account in VCD"
sudo -u cse -i vcd login vcd.vmwire.com system administrator -p Vmware1!
sudo -u cse -i echo "Enter VCD system administrator username and password to create service role"
sudo -u cse -i cse create-service-role vcd.vmwire.com

sudo -u cse -i echo "Create VCD service account for CSE"
sudo -u cse -i vcd user create --enabled svc-cse Vmware1! "CSE Service Role"
 
sudo -u cse -i echo "Create CSE config file"
sudo -u cse -i mkdir -p /opt/vmware/cse/config
 
sudo -u cse -i cat > /opt/vmware/cse/config/config-not-encrypted.conf << EOF
# Only one of the amqp or mqtt sections should be present. I am using MQTT.
 
#amqp: # I recommend using MQTT
#  exchange: cse-ext
#  host: amqp.vmware.com
#  password: guest
#  port: 5672
#  prefix: vcd
#  routing_key: cse
#  username: guest
#  vhost: /
 
mqtt:
  verify_ssl: false
 
vcd:
  api_version: '35.0'
  host: vcd.vmwire.com
  log: true
  password: Vmware1!
  port: 443
  username: administrator
  verify: true
 
# Add all vCenters that are registered in VCD
vcs:
- name: vcenter.vmwire.com
  password: Vmware1!
  username: administrator@vsphere.local
  verify: true
 
service:
  enable_tkg_m: true
  enforce_authorization: false
  log_wire: false
  processors: 15
  telemetry:
    enable: true
 
broker:
  catalog: cse-catalog
  default_template_name: ubuntu-16.04_k8-1.21_weave-2.8.1
  default_template_revision: 1
  ip_allocation_mode: pool
  network: default-organization-network
  org: cse
  remote_template_cookbook_url: https://raw.githubusercontent.com/vmware/container-service-extension-templates/master/template.yaml
  storage_profile: 'truenas-iscsi-luns'
  vdc: cse-vdc
EOF

sudo -u cse -i echo "Encrypting config file"
sudo -u cse -i cse encrypt /opt/vmware/cse/config/config-not-encrypted.conf --output /opt/vmware/cse/config/config.yaml
sudo -u cse -i chmod 600 /opt/vmware/cse/config/config.yaml
sudo -u cse -i cse check /opt/vmware/cse/config/config.yaml

sudo -u cse -i echo "List all Kubernetes templates in VCD"
sudo -u cse -i cse template list

#sudo -u cse -i echo "Setting up public keys into CSE server under ~/.ssh/authorized_keys"
#sudo -u cse -i mkdir -p /opt/vmware/cse/.ssh
# Add your public key(s) here
#sudo -u cse -i cat >> ~/.ssh/authorized_keys << EOF
#ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAhcw67bz3xRjyhPLysMhUHJPhmatJkmPUdMUEZre+MeiDhC602jkRUNVu43Nk8iD/I07kLxdAdVPZNoZuWE7WBjmn13xf0Ki2hSH/47z3ObXrd8Vleq0CXa+qRnCeYM3FiKb4D5IfL4XkHW83qwp8PuX8FHJrXY8RacVaOWXrESCnl3cSC0tA3eVxWoJ1kwHxhSTfJ9xBtKyCqkoulqyqFYU2A1oMazaK9TYWKmtcYRn27CC1Jrwawt2zfbNsQbHx1jlDoIO6FLz8Dfkm0DToanw0GoHs2Q+uXJ8ve/oBs0VJZFYPquBmcyfny4WIh4L0lwzsiAVWJ6PvzF5HMuNcwQ== rsa-key-20210508
#EOF

sudo -u cse -i echo "Install CSE" 
sudo -u cse -i cse install -k /opt/vmware/cse/.ssh/authorized_keys
 
# Or use this if you've already installed and want to skip template creation again
#sudo -u cse -i cse upgrade --skip-template-creation -k /opt/vmware/cse/.ssh/authorized_keys

sudo -u cse -i echo "Enable TKGm runtimes for CSE"
sudo -u cse -i export CSE_TKG_M_ENABLED=True
sudo -u cse -i vcd login vcd.vmwire.com system administrator -p Vmware1!

sudo -u cse -i echo "Enable a tenant to use TKGm runtimes with CSE"
sudo -u cse -i vcd cse ovdc enable tenant1-vdc -o tenant1 --tkg

sudo -u cse -i echo "Enable a tenant to use native runtimes with CSE"
sudo -u cse -i vcd cse ovdc enable --native --org tenant1 tenant1-vdc

sudo -u cse -i echo "Setup cse.sh to create a CSE Linux service"
sudo -u cse -i cat > /opt/vmware/cse/cse.sh << EOF
#!/usr/bin/env bash
source /opt/vmware/cse/python/bin/activate
export CSE_CONFIG=/opt/vmware/cse/config/config.yaml
export CSE_CONFIG_PASSWORD=Vmware1!
cse run
EOF
 
sudo -u cse -i echo "Make cse.sh executable"
sudo -u cse -i chmod +x /opt/vmware/cse/cse.sh
 
sudo -u cse -i echo "Deactivate the python virtual environment and go back to root"
sudo -u cse -i deactivate
sudo -u cse -i exit
 
echo "Setup cse.service, using MQTT instead of RabbitMQ"
cat > /etc/systemd/system/cse.service << EOF
[Unit]
Description=Container Service Extension for VMware Cloud Director
 
[Service]
ExecStart=/opt/vmware/cse/cse.sh
User=cse
WorkingDirectory=/opt/vmware/cse
Type=simple
Restart=always
 
[Install]
WantedBy=default.target
EOF

echo "Enable cse.service"
systemctl enable cse.service
echo "Start cse.service"
systemctl start cse.service
echo "Show cse.service status"
systemctl status cse.service

echo "CSE 3.0.4 succesfully installed"
