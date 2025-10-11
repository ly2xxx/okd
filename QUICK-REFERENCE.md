# OKD Quick Reference Guide

Quick command reference for managing your OKD homelab cluster.

## Installation Scripts

### PowerShell (Automated)
```powershell
# Basic installation
.\install-okd.ps1

# With custom resources
.\install-okd.ps1 -CPUs 6 -Memory 12288 -DiskSize 50

# With pull secret file
.\install-okd.ps1 -PullSecretPath "C:\Downloads\pull-secret.txt"
```

### Batch (Interactive)
```cmd
REM Right-click and "Run as administrator"
install-okd.bat
```

## Core CRC Commands

### Cluster Management
```cmd
# Check CRC version
crc version

# Setup environment (run once)
crc setup

# Start cluster
crc start

# Stop cluster (preserves state)
crc stop

# Delete cluster (removes all data)
crc delete

# Check cluster status
crc status

# Get cluster information
crc console --credentials

# Open web console in browser
crc console
```

### Configuration
```cmd
# Switch to OKD preset
crc config set preset okd

# Set CPU cores
crc config set cpus 8

# Set memory (MB)
crc config set memory 16384

# Set disk size (GB)
crc config set disk-size 60

# Enable monitoring
crc config set enable-cluster-monitoring true

# View current configuration
crc config view

# Reset to defaults
crc config unset [property]
```

### Cleanup
```cmd
# Clean up CRC resources
crc cleanup

# Delete and reset everything
crc delete
crc cleanup
```

## OpenShift CLI (oc) Commands

### Setup oc CLI

**PowerShell:**
```powershell
& crc oc-env | Invoke-Expression
```

**Command Prompt:**
```cmd
@FOR /f "tokens=*" %i IN ('crc oc-env') DO @call %i
```

### Authentication
```cmd
# Login as developer
oc login -u developer -p developer https://api.crc.testing:6443

# Login as admin
oc login -u kubeadmin https://api.crc.testing:6443

# Check current user
oc whoami

# Get login token
oc whoami -t
```

### Cluster Information
```cmd
# Cluster info
oc cluster-info

# Get nodes
oc get nodes

# Get node details
oc describe node crc

# Get cluster version
oc version

# Get API resources
oc api-resources
```

### Project Management
```cmd
# List all projects
oc projects

# Create new project
oc new-project my-app

# Switch to project
oc project my-app

# Delete project
oc delete project my-app

# Get current project
oc project
```

### Application Deployment
```cmd
# Deploy from Git repository
oc new-app https://github.com/sclorg/nodejs-ex

# Deploy from Docker image
oc new-app nginx

# Create from template
oc new-app --template=mysql-persistent

# Expose service (create route)
oc expose svc/nodejs-ex

# Scale deployment
oc scale deployment/nodejs-ex --replicas=3
```

### Viewing Resources
```cmd
# Get all resources in current project
oc get all

# Get pods
oc get pods

# Get pod details
oc describe pod [pod-name]

# Get services
oc get svc

# Get routes
oc get routes

# Get deployments
oc get deployments

# Get events
oc get events

# Get with custom output
oc get pods -o wide
oc get pods -o yaml
oc get pods -o json
```

### Pod Management
```cmd
# View pod logs
oc logs [pod-name]

# Follow logs
oc logs -f [pod-name]

# Execute command in pod
oc exec [pod-name] -- ls /

# Interactive shell
oc rsh [pod-name]

# Copy files to/from pod
oc cp [pod-name]:/path/to/file ./local-file
oc cp ./local-file [pod-name]:/path/to/file

# Delete pod
oc delete pod [pod-name]
```

### Configuration & Secrets
```cmd
# Create secret
oc create secret generic my-secret --from-literal=password=secret123

# Create configmap
oc create configmap my-config --from-literal=key=value

# Get secrets
oc get secrets

# Get configmaps
oc get configmaps

# View secret/configmap
oc describe secret my-secret
oc get configmap my-config -o yaml
```

### Build & Image Management
```cmd
# Get builds
oc get builds

# Start new build
oc start-build [build-config-name]

# View build logs
oc logs -f bc/[build-config-name]

# Get image streams
oc get is

# Import image
oc import-image myapp --from=docker.io/myimage:latest
```

### Advanced Operations
```cmd
# Edit resource
oc edit deployment/[name]

# Apply YAML file
oc apply -f deployment.yaml

# Create from YAML
oc create -f app.yaml

# Delete from YAML
oc delete -f app.yaml

# Port forwarding
oc port-forward [pod-name] 8080:8080

# Get resource usage
oc adm top nodes
oc adm top pods
```

## Web Console

### Access
- URL: https://console-openshift-console.apps-crc.testing
- Admin: `kubeadmin` / [generated password]
- Developer: `developer` / `developer`

### Quick Navigation
- **Administrator View**: Full cluster administration
- **Developer View**: Application-focused interface
- **+Add**: Deploy applications
- **Topology**: Visual application layout
- **Builds**: View build history
- **Pipelines**: CI/CD pipelines
- **Monitoring**: Metrics and alerts
- **Helm**: Deploy Helm charts
- **OperatorHub**: Install operators

## Hyper-V Management

### View CRC VM
```powershell
# Open Hyper-V Manager
virtmgmt.msc

# PowerShell commands
Get-VM crc
Get-VM crc | Get-VMNetworkAdapter
```

### Adjust VM Resources
1. Stop CRC: `crc stop`
2. Open Hyper-V Manager
3. Right-click "crc" VM → Settings
4. Modify Processor/Memory
5. Apply changes
6. Start CRC: `crc start`

## Common URLs

| Service | URL |
|---------|-----|
| Web Console | https://console-openshift-console.apps-crc.testing |
| OAuth Server | https://oauth-openshift.apps-crc.testing |
| API Server | https://api.crc.testing:6443 |
| Image Registry | default-route-openshift-image-registry.apps-crc.testing |

## Troubleshooting Commands

### Check Status
```cmd
# Detailed status
crc status

# Check version
crc version

# View configuration
crc config view
```

### Logs
```cmd
# View CRC logs (Windows)
type %USERPROFILE%\.crc\crc.log

# PowerShell
Get-Content $env:USERPROFILE\.crc\crc.log -Tail 50
```

### Reset and Cleanup
```cmd
# Stop cluster
crc stop

# Full cleanup
crc cleanup

# Delete and start fresh
crc delete
crc setup
crc start
```

### Check Hyper-V
```powershell
# Check if Hyper-V is enabled
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V

# Enable Hyper-V
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

### Network Issues
```cmd
# Check hosts file
notepad C:\Windows\System32\drivers\etc\hosts

# Re-run setup
crc setup
```

### Resource Issues
```cmd
# Reduce resources
crc config set cpus 4
crc config set memory 9216

# Check available resources
wmic cpu get NumberOfCores
wmic computersystem get TotalPhysicalMemory
```

## Useful Tips

### Persist oc CLI Setup
Add to PowerShell profile:
```powershell
# Edit profile
notepad $PROFILE

# Add this line
& crc oc-env | Invoke-Expression
```

### Quick Login Script
Create `okd-login.bat`:
```cmd
@echo off
oc login -u developer -p developer https://api.crc.testing:6443
oc project my-app
```

### Auto-Start on Boot
Create scheduled task to run `crc start` on user login.

### Stop CRC When Done
Always stop the cluster to free resources:
```cmd
crc stop
```

## Example Workflows

### Deploy a Node.js App
```cmd
# Create project
oc new-project my-nodejs-app

# Deploy from GitHub
oc new-app nodejs~https://github.com/sclorg/nodejs-ex

# Expose route
oc expose svc/nodejs-ex

# Check status
oc status

# Get route URL
oc get route nodejs-ex
```

### Deploy from Docker Image
```cmd
# Create project
oc new-project my-docker-app

# Deploy nginx
oc new-app nginx

# Expose service
oc expose svc/nginx

# Get route
oc get routes
```

### Quick Database Setup
```cmd
# Deploy MySQL
oc new-app mysql-persistent \
  -p MYSQL_USER=user \
  -p MYSQL_PASSWORD=password \
  -p MYSQL_DATABASE=mydb

# Check pods
oc get pods -w
```

## Resources

- **Documentation**: https://docs.okd.io/
- **CRC Docs**: https://crc.dev/docs
- **oc CLI Reference**: https://docs.okd.io/latest/cli_reference/openshift_cli/
- **GitHub Repo**: https://github.com/ly2xxx/okd

---

**Save this file for quick reference!** 📖
