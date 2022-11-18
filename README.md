# 5G AiaB

Deploying Aether's 5G SD-CORE with ROC using Helm Charts.

## Overview

Aether-in-a-Box (AiaB) provides an easy way to deploy Aether’s SD-CORE and ROC(Runtime Operational Control) components, and then run basic tests to validate the installation. This guide describes the steps to set up AiaB.

AiaB can be setup with a 4G or 5G SD-Core, but running both 4G and 5G SD-Core simultaneously in AiaB is currently not supported.

SD-CORE configuration can be done with or without the ROC. But the main purpose to use ROC is that it provides an interactive GUI for examining and changing the configuration, and is used to manage the production Aether. 

## Pre-requisite

* Ubuntu 18.04 or higher stable version (18.04 is a requirement of OAISIM which is used to test 4G Aether).

* Kernel 4.15 or later.

* Haswell CPU or newer.

* At least 4 CPUs and 12GB RAM.

* Ability to run `sudo` without a password. Due to this requirement, AiaB is most suited to disposable environments like a VM or a CloudLab machine.

* No firewall running on the AiaB host. For example, `sudo ufw status` should show **inactive**, and `sudo iptables -L` and `sudo nft list` should show a blank configuration.

* Install `make`.

```bash
sudo apt install -y make
```

* Install any cluster, uses `kind` in this installation. 

```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64
sudo chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

* Install `kubectl` and `kubelet`.

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update 
sudo apt-get install -y kubelet=1.21.14-00 kubectl=1.21.14-00
sudo apt-mark hold kubelet kubectl
```

* Install helm(`helmv3`).

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

## Installation

### Clone the AiaB repository

```bash
sudo apt-get update && sudo apt-get upgrade
git clone "https://gerrit.opencord.org/aether-in-a-box"
cd aether-in-a-box/
```

### Start Cluster

```bash
kind create cluster
```

### Installing the ROC for 5G using latest published charts

```bash
CHARTS=latest make roc-5g-models
```

#### Installing Aether 2.0

```bash
CHARTS=release-2.0 make roc-5g-models
```

The ROC has successfully initialized when you see output like this:

```bash
echo "ONOS CLI pod: pod/onos-cli-5b947f8f6-4r5nm"
ONOS CLI pod: pod/onos-cli-5b947f8f6-4r5nm
until kubectl -n aether-roc exec pod/onos-cli-5b947f8f6-4r5nm -- \
    curl -s -f -L -X PATCH "http://aether-roc-api:8181/aether-roc-api" \
    --header 'Content-Type: application/json' \
    --data-raw "$(cat /root/aether-in-a-box//roc-5g-models.json)"; do sleep 5; done
command terminated with exit code 22
command terminated with exit code 22
command terminated with exit code 22
"9513ea10-883d-11ec-84bf-721e388172cd"
```

Don’t worry if you see a few lines of `command terminated with exit code 22`; that command is trying to load the ROC models, and the message appears if the ROC isn’t ready yet. However if you see that message more than 10 times then something is probably wrong with the ROC or its models.

### Installing 5G SD-CORE

To deploy the 5G SD-CORE and run a test with gNBSim that performs **Registration + UE-initiated PDU Session Establishment + sends User Data packets**.

```bash
# installing SD-Core using the latest published charts
CHARTS=latest make 5g-test
```

#### Installing Aether 2.0

```bash
CHARTS=release-2.0 make 5g-test
```

To change the behavior of the test run by gNBSim, change the contents of *gnb.conf* in `sd-core-5g-values.yaml`. Consult the [gNBSim documentation](https://docs.sd-core.opennetworking.org/master/developer/gnbsim.html) for more information.

### Check Pods

```bash
kubectl get pods -A
```

## Access Dashboard

The ROC GUI is available on `port:31194` on the host running AiaB.<br>
*e.g.* **192.168.5.191:31194**

AiaB dashboard for 5G is not supported till now. But, 4G AiaB dashboard is available on `port:30950` on the host running 4G AiaB after running 

```bash
make monitoring-4g
```

*e.g.* **192.168.5.191:30950**

After this step, Grafana is available at `http://<server-ip>:30950`. You will see a number of system dashboards for monitoring Kubernetes, as well as a simple AiaB dashboard that enables inspection of the local Aether state.

## Cleanup 5G AiaB

* Clean up the 5G SD-CORE: 

```bash
make reset-5g-test
```

* Clean up the ROC: 

```bash
make roc-clean
```