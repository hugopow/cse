# Helm Chart to configure and deploy Container Service Extension and run in Kubernetes.

# Look inside the Helm directory

Use at your own risk. No support is provided.

**What is Container Service Extension?**

You can read that here https://vmware.github.io/container-service-extension/cse3_1/INTRO.html. The problem with CSE is that it is quite difficult to install. You can read up on one of my previous posts here https://vmwire.com/2021/10/14/install-container-service-extension-3-1-1-with-vcd-10-3-1/, where I described the step by step process to install CSE into a Virtual Machine.

CSE is also not available as an OVA (Virtual Appliance), so some users may find it difficult to install and configure as you need Linux knowledge.

**What Problems does this Helm chart solve?**

This helm chart can be used to configure, install and run CSE 3.1.2 on a Kubernetes cluster. The config and deployment is very simple and takes less than 5 minutes to get up and running.

You can also run multiple pods of CSE to enable high availability. Unsupported but it works.

**Installation Instructions**

The configuration and installation is a very simple process:

1. Download the helm chart from my Github repository or from my Harbor registry
2. Unzip it locally
3. Make changes to the helm chart values.yaml
4. Make changes to the config-not-encrypted.yaml which contains the CSE configuration
5. Package your changes to a new helm chart and upload to your repository
6. Install the helm chart with a single command such as helm install cse oci://<your-repo>/library/cse --version 0.1.0 -n cse -f /home/cse-helm/cse/values.yaml

Don't forget to download the photon-cse image from my Harbor registry to save both your and my bandwidth.

**Pull commands to download the bits**

helm pull oci://harbor.vmwire.com/library/cse, this pulls this helm chart

docker pull harbor.vmwire.com/library/photon-cse, this pulls the photon-cse image which is a Photon 3.0 image with the necessary pre-requisites to run CSE.
  
**Push commands to push to your repository**

helm push cse-0.1.0.tgz oci://<your-repo>/library/
