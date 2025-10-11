# OKD Homelab Setup Guide for Windows PC

![OKD Logo](https://okd.io/img/okd-panda-flat_rocketeer_with_number.svg)

## Table of Contents
- [Introduction](#introduction)
- [What is OKD?](#what-is-okd)
- [Prerequisites](#prerequisites)
- [Installation Methods](#installation-methods)
- [Quick Start with OpenShift Local (CRC)](#quick-start-with-openshift-local-crc)
- [Configuration](#configuration)
- [Accessing Your Cluster](#accessing-your-cluster)
- [Common Tasks](#common-tasks)
- [Troubleshooting](#troubleshooting)
- [Resources and References](#resources-and-references)

---

## Introduction

This guide provides comprehensive, step-by-step instructions for setting up an OKD (OpenShift Kubernetes Distribution) homelab environment on a Windows PC. OKD is the community distribution of Kubernetes that powers Red Hat OpenShift, making it an excellent platform for learning Kubernetes, container orchestration, and cloud-native application development.

## What is OKD?

**OKD** (Origin Kubernetes Distribution) is:
- The upstream, community-supported version of Red Hat OpenShift
- A Kubernetes distribution optimized for continuous application development
- Built on Fedora CoreOS (the upstream of Red Hat CoreOS)
- Includes 100+ operators and integrated tools for enterprise-grade Kubernetes

**Key Features:**
- Fully automated Kubernetes distribution
- Integrated CI/CD pipelines
- Built-in monitoring with Prometheus and Grafana
- Developer console and CLI tools
- Service mesh, image registry, and more out-of-the-box
- Multi-tenancy support

**Source:** [OKD Official Website](https://okd.io/)

---

## Prerequisites

### Hardware Requirements

**Minimum Requirements:**
- **CPU:** 4 physical CPU cores (Intel or AMD x64 architecture)
- **RAM:** 16 GB minimum (9 GB allocated to VM + host OS overhead)
- **Storage:** 35 GB of free disk space (SSD recommended)
- **Virtualization:** Windows Hyper-V capability

**Recommended Requirements:**
- **CPU:** 8+ physical CPU cores
- **RAM:** 32 GB or more (allows 16 GB for OKD cluster)
- **Storage:** 100+ GB SSD
- **Network:** Stable internet connection for downloads

### Software Requirements

- **Operating System:** Windows 10 Fall Creators Update (version 1709) or later, or Windows 11
- **Hyper-V:** Must be enabled (we'll cover this)
- **Administrator Access:** Required for Hyper-V and system configuration
- **Red Hat Developer Account:** Free account at [Red Hat Developer Program](https://developers.redhat.com/)

**Source:** [CRC Documentation - Requirements](https://crc.dev/docs/using/)

---

## Installation Methods

There are three main approaches to running OKD on Windows:

### 1. **OpenShift Local (CRC)** - ⭐ RECOMMENDED FOR WINDOWS
The easiest and fastest way to get started. Runs a single-node OKD cluster in a VM on your Windows PC.
- **Best for:** Learning, development, testing
- **Setup time:** 30-60 minutes
- **Complexity:** Low

### 2. **Full Cluster Installation on Hypervisor**
Install full OKD cluster using VMs on Hyper-V, VMware Workstation, or VirtualBox.
- **Best for:** Production-like testing, multi-node setups
- **Setup time:** 2-4 hours
- **Complexity:** High

### 3. **Cloud Provider Installation**
Use the openshift-installer to deploy on AWS, Azure, or GCP.
- **Best for:** Cloud environment simulation
- **Setup time:** 30-60 minutes
- **Complexity:** Medium (requires cloud account)

**This guide focuses on Method 1 (OpenShift Local/CRC)** as it's the most practical for Windows homelabs.

---

## Quick Start with OpenShift Local (CRC)

### Step 1: Enable Hyper-V on Windows

OpenShift Local requires Hyper-V to run the virtual machine.

1. **Open PowerShell as Administrator**
   - Press `Win + X` and select "Windows PowerShell (Admin)" or "Terminal (Admin)"

2. **Enable Hyper-V**
   ```powershell
   Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
   ```

3. **Reboot your computer** when prompted
   ```powershell
   Restart-Computer
   ```

**Alternative (Using Windows GUI):**
1. Open "Control Panel" → "Programs" → "Turn Windows features on or off"
2. Check the boxes for:
   - ✅ Hyper-V
   - ✅ Windows Hypervisor Platform
   - ✅ Virtual Machine Platform
3. Click "OK" and restart

**Source:** [Installing Red Hat OpenShift Local on Windows 11](https://zxtech.wordpress.com/2024/05/12/installing-red-hat-openshift-local-on-windows-11/)

### Step 2: Create Red Hat Developer Account

1. Go to [Red Hat Developer Program](https://developers.redhat.com/register)
2. Fill out the registration form (free)
3. Verify your email address
4. Log in to your new account

### Step 3: Download OpenShift Local (CRC)

1. Navigate to [OpenShift Local Download Page](https://console.redhat.com/openshift/create/local)
2. Log in with your Red Hat Developer account
3. Select **Windows** from the platform dropdown
4. Click **"Download OpenShift Local"** (downloads `crc-windows-installer.zip`)
5. Click **"Download pull secret"** (downloads `pull-secret.txt`)
   - Keep this file safe - you'll need it during setup

**Source:** [Red Hat OpenShift Local Download](https://console.redhat.com/openshift/create/local)

### Step 4: Install OpenShift Local

1. **Extract the downloaded ZIP file**
   - Right-click `crc-windows-installer.zip` → "Extract All"
   - You should see `crc-windows-amd64.msi`

2. **Run the installer**
   - Double-click `crc-windows-amd64.msi`
   - Click "Next" through the installation wizard
   - Accept the license agreement
   - Choose installation location (default: `C:\Program Files\Red Hat OpenShift Local\`)
   - Click "Install"

3. **Complete installation**
   - The installer will:
     - Add CRC to your system PATH
     - Modify your Windows hosts file for DNS resolution
     - Configure Hyper-V networking
   - Click "Finish"

4. **Restart your computer** (recommended to ensure all changes take effect)

**Source:** [Installing Red Hat OpenShift Local on Windows 11](https://zxtech.wordpress.com/2024/05/12/installing-red-hat-openshift-local-on-windows-11/)

### Step 5: Configure for OKD Preset

By default, CRC uses the Red Hat OpenShift preset. To use the free OKD distribution instead:

1. **Open a new Command Prompt or PowerShell**

2. **Verify CRC installation**
   ```cmd
   crc version
   ```
   You should see version information for CRC, OpenShift, and Podman.

3. **Switch to OKD preset** (IMPORTANT!)
   ```cmd
   crc config set preset okd
   ```

4. **Configure resources** (optional but recommended)
   ```cmd
   crc config set cpus 8
   crc config set memory 16384
   crc config set disk-size 60
   ```
   
   Adjust these values based on your system:
   - `cpus`: Number of CPU cores (4-12 recommended)
   - `memory`: RAM in MB (minimum 9216, recommended 16384 or more)
   - `disk-size`: Disk space in GB (minimum 35, recommended 60+)

5. **View your configuration**
   ```cmd
   crc config view
   ```

**Sources:** 
- [Openshift Local Installation Guide](https://thingsandcode.com/openshift/install-openshift-local/)
- [Using CRC Documentation](https://crc.dev/docs/using/)

### Step 6: Setup CRC Environment

Run the setup command to prepare your system:

```cmd
crc setup
```

This command will:
- ✅ Check system requirements
- ✅ Download the OKD VM image (~2-3 GB, takes 10-30 minutes)
- ✅ Configure Hyper-V networking
- ✅ Create necessary host file entries
- ✅ Set up the CRC daemon

**Note:** A separate terminal window will open for the CRC daemon. **Do not close this window** - it needs to run in the background.

**Source:** [Configuring OpenShift Local](https://zxtech.wordpress.com/2024/05/12/configuring-openshift-local/)

### Step 7: Start Your OKD Cluster

1. **Start the cluster**
   ```cmd
   crc start
   ```

2. **Enter your pull secret when prompted**
   - Open the `pull-secret.txt` file you downloaded earlier
   - Copy the entire JSON content
   - Paste it at the prompt (it will appear as `***` for security)
   - Press Enter

3. **Wait for startup** (first start takes 10-15 minutes)
   - The cluster needs to download container images
   - System will perform health checks
   - You'll see progress messages

4. **Cluster is ready!** When you see:
   ```
   Started the OpenShift cluster.
   
   The server is accessible via web console at:
     https://console-openshift-console.apps-crc.testing
   
   Log in as administrator:
     Username: kubeadmin
     Password: XXXXX-XXXXX-XXXXX-XXXXX
   
   Log in as user:
     Username: developer
     Password: developer
   ```

**Save the kubeadmin password** - you'll need it to access the cluster as admin!

**Sources:**
- [Configuring OpenShift Local](https://zxtech.wordpress.com/2024/05/12/configuring-openshift-local/)
- [How to Install Red Hat OpenShift Local](https://www.redhat.com/en/blog/install-openshift-local)

---

## Configuration

### Adjusting VM Resources

If you need to change resources after initial setup:

```cmd
crc stop
crc delete
crc config set cpus 8
crc config set memory 16384
crc setup
crc start
```

### Enabling Cluster Monitoring

To enable Prometheus/Grafana monitoring (requires more resources):

```cmd
crc config set enable-cluster-monitoring true
crc setup
crc start
```

### Changing Preset

To switch between presets:

```cmd
crc stop
crc delete
crc config set preset [openshift|okd|microshift]
crc setup
crc start
```

**Source:** [Using CRC Documentation](https://crc.dev/docs/using/)

---

## Accessing Your Cluster

### Web Console Access

1. **Open the console in your browser**
   ```cmd
   crc console
   ```
   This automatically opens `https://console-openshift-console.apps-crc.testing` in your default browser.

2. **Accept the self-signed certificate**
   - Click "Advanced" → "Accept the Risk and Continue" (Firefox)
   - Or "Advanced" → "Proceed to site" (Chrome/Edge)

3. **Log in**
   - **As Administrator:**
     - Username: `kubeadmin`
     - Password: (from the `crc start` output)
   
   - **As Developer:**
     - Username: `developer`
     - Password: `developer`

**Tip:** Use the developer user for learning and creating projects. Use kubeadmin only when you need admin privileges.

### Command Line Access

1. **Set up the OpenShift CLI (oc)**
   ```cmd
   crc oc-env
   ```
   This displays the path to add to your environment.

2. **For PowerShell, run:**
   ```powershell
   & crc oc-env | Invoke-Expression
   ```

3. **For Command Prompt, run:**
   ```cmd
   @FOR /f "tokens=*" %i IN ('crc oc-env') DO @call %i
   ```

4. **Verify oc is available**
   ```cmd
   oc version
   ```

5. **Log in via CLI**
   ```cmd
   oc login -u developer https://api.crc.testing:6443
   ```
   Or as admin:
   ```cmd
   oc login -u kubeadmin https://api.crc.testing:6443
   ```

6. **View cluster info**
   ```cmd
   oc cluster-info
   oc get nodes
   oc get projects
   ```

**Sources:**
- [Configuring OpenShift Local](https://zxtech.wordpress.com/2024/05/12/configuring-openshift-local/)
- [Red Hat OpenShift Local Guide](https://openshift.guide/getting-started/openshift-local.html)

---

## Common Tasks

### Creating Your First Project

```cmd
oc new-project my-first-app
```

### Deploying a Sample Application

```cmd
oc new-app https://github.com/sclorg/nodejs-ex
oc expose svc/nodejs-ex
oc get routes
```

Visit the route URL to see your application!

### Stopping the Cluster

```cmd
crc stop
```
This freezes the cluster state - use when you're done for the day but want to preserve your work.

### Starting the Cluster Again

```cmd
crc start
```
Much faster than the first start (1-2 minutes).

### Completely Removing the Cluster

```cmd
crc stop
crc delete
```
Use this to start fresh or free up disk space.

### Checking Cluster Status

```cmd
crc status
```

### Getting Console Credentials

```cmd
crc console --credentials
```

**Source:** [Red Hat OpenShift Local Guide](https://openshift.guide/getting-started/openshift-local.html)

---

## Troubleshooting

### Issue: "Virtualization is not enabled"

**Solution:**
1. Restart your computer
2. Enter BIOS/UEFI (usually F2, F10, F12, or Del during boot)
3. Find and enable:
   - Intel: "Intel VT-x" or "Virtualization Technology"
   - AMD: "AMD-V" or "SVM Mode"
4. Save and exit BIOS

### Issue: "Not enough memory to start the VM"

**Solution:**
```cmd
crc stop
crc config set memory 9216
crc start
```
Close unnecessary applications to free up RAM.

### Issue: "Cannot resolve apps-crc.testing"

**Solution:**
1. Check your hosts file has CRC entries: `C:\Windows\System32\drivers\etc\hosts`
2. Run as Administrator:
   ```cmd
   crc setup
   ```
3. Restart CRC:
   ```cmd
   crc stop
   crc start
   ```

### Issue: Certificate errors in browser

**Solution:**
This is expected with self-signed certificates. Click "Advanced" and accept the security exception.

### Issue: CRC daemon terminal closed

**Solution:**
1. Close all CRC processes
2. Run `crc setup` again
3. Keep the daemon terminal window open

### Issue: Hyper-V VM performance is slow

**Solution:**
1. Open Hyper-V Manager
2. Right-click on the "crc" VM → Settings
3. Increase processor count to match your physical cores
4. Enable "Dynamic Memory" under Memory settings
5. Increase maximum RAM allocation

**Sources:**
- [Openshift Local Installation Guide - Troubleshooting](https://thingsandcode.com/openshift/install-openshift-local/)
- [Trying out CRC - Comments](https://www.jeffgeerling.com/blog/2019/trying-out-crc-code-ready-containers-run-openshift-4x-locally)

---

## Resources and References

### Official Documentation

1. **OKD Project**
   - Official Website: https://okd.io/
   - GitHub Repository: https://github.com/okd-project/okd
   - Documentation: https://docs.okd.io/

2. **OpenShift Local (CRC)**
   - Official Documentation: https://crc.dev/docs
   - GitHub Repository: https://github.com/crc-org/crc
   - Download Page: https://console.redhat.com/openshift/create/local

3. **Red Hat Developer**
   - Developer Program: https://developers.redhat.com/
   - Installation Guide: https://www.redhat.com/en/blog/install-openshift-local
   - OpenShift Guide: https://openshift.guide/getting-started/openshift-local.html

### Community Resources

4. **Installation Guides**
   - Installing on Windows 11: https://zxtech.wordpress.com/2024/05/12/installing-red-hat-openshift-local-on-windows-11/
   - Configuring OpenShift Local: https://zxtech.wordpress.com/2024/05/12/configuring-openshift-local/
   - Openshift Local Installation: https://thingsandcode.com/openshift/install-openshift-local/

5. **Homelab Setups**
   - Guide to Installing OKD 4.5 in Home Lab: https://www.redhat.com/en/blog/guide-to-installing-an-okd-4-4-cluster-on-your-home-lab
   - Building OKD Lab: https://cgruver.github.io/okd4-upi-lab-setup/
   - Building OKD Homelab on Proxmox: https://medium.com/@PlanB./building-an-okd-homelab-on-proxmox-just-got-way-easier-heres-how-357c8774a7a5
   - Sri's Overkill Homelab: https://okd.io/docs/project/guides/sri/
   - Vadim's Homelab: https://okd.io/docs/project/guides/vadim/

6. **Advanced Topics**
   - Deploying OKD 4.17: https://medium.com/@josephsims1/deploying-okd-4-17-practical-steps-for-success-8ff3510be81e
   - Homelab Setup with AlmaLinux: https://medium.com/@josephsims1/homelab-setup-running-rke2-and-okd-on-almalinux-5d98bba3783f
   - Building Portable Kubernetes Lab: https://upstreamwithoutapaddle.com/home-lab/lab-intro/

### Learning Resources

7. **Kubernetes & OpenShift**
   - OpenShift Documentation: https://docs.okd.io/latest/welcome/
   - Source-to-Image (S2I): https://github.com/openshift/source-to-image
   - Container Images: https://github.com/openshift/library/tree/master/official

8. **Community Support**
   - Kubernetes Slack #openshift-users: https://kubernetes.slack.com/archives/C6AD6JM17
   - OKD Mailing List: https://lists.openshift.redhat.com/openshiftmm/listinfo/dev
   - OKD Working Group Meetings: https://calendar.fedoraproject.org/okd/
   - GitHub Issues: https://github.com/openshift/okd/issues

---

## Next Steps

Once you have OKD running, explore:

1. **Deploy applications** using Source-to-Image (S2I)
2. **Set up CI/CD pipelines** with Tekton
3. **Install Operators** from OperatorHub
4. **Configure monitoring** with Prometheus and Grafana
5. **Try service mesh** with Istio
6. **Practice with oc CLI** commands
7. **Build custom applications** and deploy them

---

## Contributing

Found an issue or have an improvement? Feel free to:
- Open an issue on this repository
- Submit a pull request
- Share your OKD homelab setup experiences

---

## License

This guide is provided as-is for educational purposes. OKD is licensed under the Apache License 2.0.

---

**Last Updated:** October 2025  
**Maintained by:** GitHub Community

---

## Acknowledgments

This guide was compiled from various community resources, official documentation, and real-world implementations. Special thanks to:
- The OKD Project team
- Red Hat Developer Relations
- Community contributors who shared their homelab experiences
- Everyone who has written tutorials and guides on running OKD

---

**Enjoy your OKD homelab journey! 🚀**
