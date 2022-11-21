# 5G AiaB

Deploying Aether's 5G SD-CORE with ROC using Helm Charts. [Official Documentation](https://docs.aetherproject.org/master/developer/aiab.html#installing-the-5g-aiab)

## Overview

Aether-in-a-Box (AiaB) provides an easy way to deploy Aether’s SD-CORE and ROC(Runtime Operational Control) components, and then run basic tests to validate the installation. This guide describes the steps to set up AiaB.

AiaB can be setup with a 4G or 5G SD-Core, but running both 4G and 5G SD-Core simultaneously in AiaB is currently not supported.

SD-CORE configuration can be done with or without the ROC. But the main purpose to use ROC is that it provides an interactive GUI for examining and changing the configuration, and is used to manage the production Aether. 

## Pre-requisite

* Ubuntu 18.04 or higher stable version (18.04 is a requirement of OAISIM which is used to test 4G Aether).

* Kernel 4.15 or later.

* Haswell CPU or newer.

* At least `4 CPUs` and `12GB RAM`.

* Ability to run `sudo` without a password. Due to this requirement, AiaB is most suited to disposable environments like a VM or a CloudLab machine.

* No firewall running on the AiaB host. For example, `sudo ufw status` should show **inactive**, and `sudo iptables -L` and `sudo nft list` should show a blank configuration.

* Install Dependencies(`make`, `docker`, `kind`, `kubectl`, `kubelet`, `helm`):

```bash
git clone https://github.com/ShubhamKumar89/5G-AiaB
cd 5G-AiaB/
chmod 777 dependency.sh
./dependency.sh
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

![image](https://user-images.githubusercontent.com/97805339/202686731-033288e2-89ca-4b44-82d3-5c06bcf2eddf.png)


AiaB dashboard for 5G is not supported till now. But, 4G AiaB dashboard is available on `port:30950` on the host running 4G AiaB after running:

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
