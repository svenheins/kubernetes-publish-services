# kubernetes-publish-services

Deploying several applications via kubernetes. Here we demonstrate how to create a deployment based on a Dockerfile, run a service and an ingress in order to expose the deployment to a given url.

## prerequisites

- envsubst: apt install gettext
- DNS-entry: you may have to add the respective DNS entry or change your /etc/hosts for quick testing

## launch

Run the following scripts:

1. 01_podman_build_push.sh to build and push the image
2. 02_deploy.sh to deploy the stack with additional env variables
3. 03_delete.sh to stop and remove the stack from kubernetes

## VPN-Access
If you want to connect via VPN and your Kubernetes network is in a different VLAN you can use any jump-server in order to test your app:
```
ssh -L <localhost-port-80>:<kubernetes-host-ip>:<kubernetes-host-port-80> -L <localhost-port-8443>:<kubernetes-host-ip>:<kubernetes-host-port-443> <accessible-host-ip>
```