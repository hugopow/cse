# cse

A example bash script to setup Container Service Extension 3.0.4 into VMware Photon OS 3.
You will need to remove my settings and replace them with your environment variables and passwords.
Just run on the Photon VM that will be running the CSE service.
This VM needs to be able to access the VCD portal over 443 and also the vCenter Servers that are registered in VCD as PVDCs.

Please refer to these two links to get familiar with Container Service Extension and preparing the Photon VM for CSE.
1. https://vmwire.com/2021/08/10/install-guide-container-service-extension-3-0-4-with-vmware-cloud-director-for-tanzu-kubernetes-grid/
2. https://vmwire.com/2021/08/21/install-container-service-extension-as-a-service-on-photon-os-3/


Get the script to the Photon VM by running the following command

curl https://raw.githubusercontent.com/hugopow/cse/main/cse-install.sh --output cse-install.sh
