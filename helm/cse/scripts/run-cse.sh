#!/bin/sh
# Script to configure and run CSE as a container, use at your own risk, no support is given.
# Tested in Kubernetes 1.22.5, Tanzu Kubernetes Grid

# Set environment variables
cat >> ~/.bash_profile << EOF
# For Container Service Extension
export CSE_CONFIG=/opt/vmware/cse/config/config.yaml
export CSE_CONFIG_PASSWORD=Vmware1!
source /opt/vmware/cse/python/bin/activate
EOF

# Set bash profile
echo "Reload bash profile"
source ~/.bash_profile

# Setup vcd cli for cse
mkdir -p ~/.vcd-cli
cat >  ~/.vcd-cli/profiles.yaml << EOF
extensions:
- container_service_extension.client.cse
EOF

# Create service account, if already done previously then comment this section out.
#vcd login vcd.vmwire.com system administrator -p Vmware1!
#cse create-service-role vcd.vmwire.com
# Enter system administrator username and password
 
# Create VCD service account for CSE, if already done previously then comment this section out.
#vcd user create --enabled svc-cse Vmware1! "CSE Service Role"
 
# Encrypt config file and set permissionsa
echo " Encrypt config file, place into /opt/vmware/cse/config/config.yaml and make executable"
cse encrypt /home/vmware/config-not-encrypted.conf  --output /opt/vmware/cse/config/config.yaml
chmod 600 /opt/vmware/cse/config/config.yaml

# Check config file
echo "Checking config file is valid"
cse check /opt/vmware/cse/config/config.yaml

# List templates
echo "List current available templates for Kubernetes nodes"
cse template list

# Install CSE, comment out if CSE is already installed in your environment, for example deployed in a VM. This helm chart can replace the VM.
#cse install -c /opt/vmware/cse/config/config.yaml

# Install CSE
#cse upgrade -c /opt/vmware/cse/config/config.yaml

# Setup cse.sh
cat > /opt/vmware/cse/cse.sh << EOF
#!/usr/bin/env bash
source /opt/vmware/cse/python/bin/activate
export CSE_CONFIG=/opt/vmware/cse/config/config.yaml
export CSE_CONFIG_PASSWORD=Vmware1!
cd /opt/vmware/cse
nohup cse run --config /opt/vmware/cse/config/config.yaml > nohup.out 2>&1 &
EOF

# Make cse.sh executable
chmod +x /opt/vmware/cse/cse.sh

# Run CSE
echo "Start Container Service Extension"
./opt/vmware/cse/cse.sh
echo "CSE started successfully"

# Tail the logs
sleep 10
echo "Show CSE logs"
tail -f /opt/vmware/cse/nohup.out -f /root/.cse-logs/cse-server-info.log -f /root/.cse-logs/cse-server-debug.log
