# 🐮 Rancher UI Integration with OKD Homelab

**Project:** Expand OKD homelab to include Rancher multi-cluster management  
**Created:** 2026-03-05  
**Owner:** Master Yang

---

## 🎯 Overview

**Goal:** Add Rancher UI to your existing OKD homelab for unified multi-cluster management, enhanced observability, and centralized access control.

**What is Rancher?**
- Multi-cluster Kubernetes management platform (by SUSE)
- Provides unified UI for managing multiple K8s clusters (vanilla K8s, EKS, GKE, AKS, **and OpenShift/OKD**)
- Centralized authentication (OIDC, LDAP, AD integration)
- Fleet-level monitoring and GitOps capabilities
- Application catalog and Helm chart management

---

## ✅ Research Summary: Is Rancher + OKD Possible?

### **Answer: YES! ✅**

**Key Findings:**

1. **Rancher CAN import OpenShift/OKD clusters**
   - Rancher is designed to manage ANY Kubernetes cluster
   - Import method: Generate import manifest in Rancher → Apply to OKD cluster

2. **How it works:**
   - Rancher connects to OKD via Kubernetes API
   - Uses service account credentials (cluster-admin level)
   - Rancher agent pod runs in OKD cluster for monitoring
   - RBAC mappings flow from Rancher into OKD's native RBAC

3. **Benefits of combining OKD + Rancher:**
   - ✅ Unified authentication (single login across clusters)
   - ✅ Fleet-level monitoring (view all clusters from one dashboard)
   - ✅ Centralized RBAC management
   - ✅ GitOps integration (fleet management)
   - ✅ Application catalog access
   - ✅ Consolidated audit trail

4. **Use Case:**
   - **OKD handles:** Workload scheduling, networking, security contexts
   - **Rancher handles:** Multi-cluster orchestration, identity, templates, observability

5. **Real-world examples:**
   - Companies run Rancher + OpenShift together for hybrid/multi-cloud
   - Common pattern: Rancher as "management plane", OKD as "workload plane"

---

## 🏗️ Architecture: OKD + Rancher Integration

```
┌─────────────────────────────────────────────────────────────┐
│                     Rancher Manager UI                      │
│              https://rancher.yourdomain.local                │
│                                                              │
│  • Unified Dashboard                                        │
│  • Multi-Cluster Management                                 │
│  • Centralized Authentication (OIDC/LDAP)                   │
│  • Fleet GitOps                                             │
│  • Monitoring & Alerting                                    │
└─────────────────────┬───────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        │             │             │
        ▼             ▼             ▼
┌───────────┐  ┌───────────┐  ┌───────────┐
│ OKD CRC   │  │ K3s/RKE2  │  │ EKS/GKE   │
│ (Local)   │  │ (Homelab) │  │ (Cloud)   │
│           │  │           │  │           │
│ Imported  │  │ Created   │  │ Imported  │
│ Cluster   │  │ by Rancher│  │ Cluster   │
└───────────┘  └───────────┘  └───────────┘
```

**Your current setup:** OKD CRC (single-node local cluster)  
**After Rancher:** Rancher Manager + OKD (imported) + potential for more clusters

---

## 📋 Prerequisites

### Hardware Requirements

**For Rancher + OKD on same machine:**
- **CPU:** 8+ cores (4 for OKD, 2 for Rancher, 2 for host)
- **RAM:** 24+ GB (16 GB for OKD, 6 GB for Rancher, 2 GB for host)
- **Disk:** 100+ GB SSD

**Alternative: Separate VMs**
- Run Rancher in separate VM/container (recommended)
- Keep OKD CRC in its own VM
- Lighter footprint per component

### Software Requirements

- ✅ **OKD CRC running** (you already have this)
- ⏳ **Docker Desktop or Podman** (for running Rancher container)
- ⏳ **kubectl/oc CLI** (you have oc, kubectl is similar)
- ⏳ **Helm 3** (for Rancher installation)

---

## 🚀 Installation Options

### **Option 1: Rancher in Docker (Recommended for Testing)**

**Pros:**
- Fastest setup (5-10 minutes)
- Runs on Windows with Docker Desktop
- Easy to remove/reinstall

**Cons:**
- Not for production
- Single container (no HA)

**Steps:**

1. **Install Docker Desktop**
   - Download from: https://www.docker.com/products/docker-desktop
   - Enable WSL 2 backend
   - Allocate 4 GB RAM, 2 CPUs

2. **Run Rancher container**
   ```powershell
   docker run -d --restart=unless-stopped `
     -p 8080:80 -p 8443:443 `
     --name rancher `
     --privileged `
     rancher/rancher:latest
   ```

3. **Access Rancher UI**
   - Wait 2-3 minutes for startup
   - Visit: https://localhost:8443
   - Get bootstrap password:
     ```powershell
     docker logs rancher 2>&1 | Select-String "Bootstrap Password:"
     ```

4. **Initial setup**
   - Accept self-signed cert
   - Enter bootstrap password
   - Set new admin password
   - Accept EULA
   - Choose "I don't want Rancher to collect data"

---

### **Option 2: Rancher on Kubernetes (Production-Ready)**

**Pros:**
- Production-grade HA setup
- Runs on any Kubernetes (including OKD!)
- Better resource management

**Cons:**
- More complex setup
- Requires Helm knowledge
- Higher resource usage (runs on OKD cluster)

**Steps:**

1. **Install Helm**
   ```powershell
   # Download Helm 3
   curl https://get.helm.sh/helm-v3.14.0-windows-amd64.zip -o helm.zip
   Expand-Archive helm.zip
   # Add to PATH
   ```

2. **Add Rancher Helm repo**
   ```bash
   helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
   helm repo update
   ```

3. **Create namespace in OKD**
   ```bash
   oc create namespace cattle-system
   ```

4. **Install cert-manager** (required for Rancher)
   ```bash
   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.yaml
   ```

5. **Install Rancher**
   ```bash
   helm install rancher rancher-stable/rancher `
     --namespace cattle-system `
     --set hostname=rancher.apps-crc.testing `
     --set bootstrapPassword=admin `
     --set ingress.tls.source=rancher
   ```

6. **Wait for deployment**
   ```bash
   oc -n cattle-system rollout status deploy/rancher
   ```

7. **Access Rancher**
   - URL: https://rancher.apps-crc.testing
   - Username: admin
   - Password: (the bootstrap password you set)

---

### **Option 3: Rancher on separate K3s cluster (Recommended for Homelab)**

**Pros:**
- Best separation of concerns
- Rancher doesn't consume OKD resources
- K3s is lightweight (1 GB RAM, 1 CPU)
- Production-like multi-cluster setup

**Cons:**
- Requires second VM or machine

**Steps:**

1. **Install K3s** (on separate Windows VM with WSL or Linux VM)
   ```bash
   curl -sfL https://get.k3s.io | sh -
   ```

2. **Get kubeconfig**
   ```bash
   sudo cat /etc/rancher/k3s/k3s.yaml > kubeconfig.yaml
   ```

3. **Install Rancher on K3s**
   ```bash
   helm install rancher rancher-stable/rancher \
     --namespace cattle-system \
     --create-namespace \
     --set hostname=rancher.local \
     --set bootstrapPassword=admin
   ```

4. **Access Rancher**
   - Add DNS entry: `192.168.x.x rancher.local` to hosts file
   - Visit: https://rancher.local

---

## 🔗 Importing OKD into Rancher

### Step-by-Step Import Process

1. **Log into Rancher UI**
   - https://localhost:8443 (if using Docker option)
   - Or your configured hostname

2. **Add OKD cluster**
   - Click "Cluster Management" (☰ menu)
   - Click "Import Existing"
   - Select "Generic" (not specific cloud provider)
   - Give it a name: "okd-local" or "okd-crc"

3. **Configure import**
   - **Cluster Name:** `okd-local`
   - **Description:** "Local OKD CRC cluster for development"
   - Click "Create"

4. **Get import manifest**
   - Rancher generates a `kubectl` command
   - It looks like:
     ```bash
     curl --insecure -sfL https://rancher.local/v3/import/xxx.yaml | kubectl apply -f -
     ```

5. **Apply to OKD cluster**
   - Open PowerShell with OKD access (`oc login`)
   - Run the command (replace `kubectl` with `oc`):
     ```bash
     curl --insecure -sfL https://localhost:8443/v3/import/xxx.yaml | oc apply -f -
     ```
   - This creates `cattle-system` namespace in OKD
   - Installs Rancher agent pods

6. **Wait for connection**
   - Agent registers with Rancher
   - Status changes to "Active" (green)
   - Usually takes 1-2 minutes

7. **Verify**
   - Click on "okd-local" cluster
   - You should see cluster metrics, nodes, workloads
   - Try clicking "Kubectl Shell" → you're now in OKD!

---

## 🎨 What You Can Do with Rancher + OKD

### 1. **Unified Dashboard**
- View all clusters from one UI
- See resource usage across clusters
- Monitor node health

### 2. **Centralized Authentication**
- Set up OIDC (Okta, Azure AD, Google)
- Users log in once, access all clusters
- No need to manage kubeconfigs

### 3. **RBAC Management**
- Define global roles in Rancher
- Map to Kubernetes/OpenShift roles
- Grant developers cluster access without SSH

### 4. **GitOps with Fleet**
- Define deployments in Git
- Rancher auto-deploys to clusters
- Perfect for multi-env (dev/staging/prod)

### 5. **Application Catalog**
- Browse Helm charts
- One-click deploy to OKD
- Marketplace for common apps

### 6. **Monitoring & Alerting**
- Built-in Prometheus/Grafana
- Cluster-level and app-level metrics
- Alerts to Slack, email, PagerDuty

### 7. **Backup & Disaster Recovery**
- Scheduled cluster backups
- etcd snapshots
- Restore points

---

## 📊 Expected Resource Usage

**OKD CRC (existing):**
- CPU: 8 cores
- RAM: 16 GB
- Disk: 60 GB

**Rancher Manager (Docker):**
- CPU: 2 cores
- RAM: 4 GB
- Disk: 10 GB

**Rancher Agent (running in OKD):**
- CPU: 0.5 cores
- RAM: 512 MB
- Disk: 1 GB

**Total:**
- CPU: 10-11 cores
- RAM: 20-21 GB
- Disk: 71 GB

**Recommendation:** If your machine has 32 GB RAM and 12+ cores, you're golden. Otherwise, consider reducing OKD to 8 GB RAM + 4 CPUs.

---

## 🛠️ Quick Start: Rancher + OKD (Full Workflow)

### Phase 1: Install Rancher (Option 1 - Docker)

```powershell
# Install Docker Desktop first (manual download + install)

# Run Rancher
docker run -d --restart=unless-stopped `
  -p 8080:80 -p 8443:443 `
  --name rancher `
  --privileged `
  rancher/rancher:latest

# Wait 2-3 minutes, then get password
docker logs rancher 2>&1 | Select-String "Bootstrap Password:"

# Open browser
Start-Process https://localhost:8443
```

### Phase 2: Set Up Rancher

1. Accept self-signed cert warning
2. Enter bootstrap password
3. Set new admin password (save it!)
4. Accept EULA
5. Choose "Local" or set server URL

### Phase 3: Import OKD Cluster

1. In Rancher UI: Cluster Management → Import Existing
2. Name: `okd-local`
3. Copy the `kubectl apply` command
4. In PowerShell:
   ```powershell
   # Log into OKD first
   oc login -u kubeadmin https://api.crc.testing:6443
   
   # Apply import manifest (replace with your actual URL)
   curl --insecure -sfL https://localhost:8443/v3/import/xxx.yaml | oc apply -f -
   ```
5. Back in Rancher: Watch cluster turn "Active" (green)

### Phase 4: Explore

- Click on "okd-local" cluster
- Browse deployments, services, nodes
- Try "Kubectl Shell" → terminal to cluster
- Check "Monitoring" → see Prometheus metrics
- Go to "Apps" → install a Helm chart

---

## 📚 Learning Path

### Week 1: Basics
- ✅ Install Rancher (Docker method)
- ✅ Import OKD cluster
- ✅ Explore Rancher UI
- ✅ Try kubectl shell access

### Week 2: Authentication
- ⏳ Set up local authentication
- ⏳ Create users/teams
- ⏳ Assign cluster roles
- ⏳ Test access from different users

### Week 3: Monitoring
- ⏳ Enable monitoring on OKD cluster
- ⏳ View Prometheus metrics
- ⏳ Create custom dashboards
- ⏳ Set up alerting rules

### Week 4: GitOps
- ⏳ Install Fleet
- ⏳ Connect Git repo
- ⏳ Deploy app via GitOps
- ⏳ Test auto-sync

---

## 🚨 Known Issues & Workarounds

### Issue 1: OpenShift-specific features may not work in Rancher

**Problem:** OKD has Routes, Projects, and other OpenShift-specific resources that Rancher doesn't natively understand.

**Workaround:**
- Use `oc` CLI for OpenShift-specific tasks
- Rancher handles standard Kubernetes resources fine
- For advanced OKD features, use OKD console directly

### Issue 2: Certificate trust

**Problem:** Self-signed certs between Rancher and OKD

**Workaround:**
- Use `--insecure` flag during import
- Or set up proper CA-signed certs (advanced)

### Issue 3: Resource contention on single machine

**Problem:** Running both Rancher and OKD on one Windows PC can be heavy

**Workaround:**
- Reduce OKD to 8 GB RAM, 4 CPUs
- Run Rancher in Docker (lightweight)
- Or use separate machine/VM for Rancher

---

## 🎯 Next Steps (After Reading This)

**Phase 1: Research (DONE ✅)**
- ✅ Research if Rancher + OKD is possible
- ✅ Understand architecture
- ✅ Clone okd repo

**Phase 2: Environment Prep (TODO)**
- ⏳ Check if Docker Desktop is installed
- ⏳ Verify OKD CRC is running (`crc status`)
- ⏳ Check available RAM/CPU (`Get-WmiObject Win32_ComputerSystem`)

**Phase 3: Install Rancher (TODO)**
- ⏳ Choose installation method (recommend Docker for testing)
- ⏳ Run Rancher container
- ⏳ Complete initial setup

**Phase 4: Import OKD (TODO)**
- ⏳ Create import manifest in Rancher
- ⏳ Apply to OKD cluster
- ⏳ Verify connection

**Phase 5: Explore (TODO)**
- ⏳ Browse cluster in Rancher UI
- ⏳ Deploy test app via Rancher
- ⏳ Set up monitoring
- ⏳ Try GitOps

---

## 📖 Resources

**Official Documentation:**
- Rancher Docs: https://ranchermanager.docs.rancher.com/
- Importing Clusters: https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/kubernetes-clusters-in-rancher-setup/register-existing-clusters
- OKD + Rancher: https://hoop.dev/blog/what-openshift-rancher-actually-does-and-when-to-use-it/

**Videos:**
- Rancher Quick Start: https://www.youtube.com/watch?v=oRLaD2k0IOI
- Import Existing Cluster: https://www.youtube.com/watch?v=Q-DLCJWOkfA

**Community:**
- Rancher Forums: https://forums.rancher.com/
- Rancher Slack: https://slack.rancher.io/

---

## 💡 Pro Tips

1. **Start with Docker method** - Easiest to test, easy to remove
2. **Don't over-allocate resources** - Better to start small and scale up
3. **Use OKD console for OpenShift features** - Rancher for multi-cluster, OKD for OKD-specific
4. **Document your setup** - Hostnames, passwords, resource allocations
5. **Backup before import** - Take OKD snapshot before connecting Rancher

---

## ✅ Decision: Should You Do This?

**YES, if:**
- ✅ You want to learn multi-cluster management
- ✅ You plan to add more K8s clusters (K3s, GKE, EKS)
- ✅ You want unified auth/RBAC across clusters
- ✅ You have 24+ GB RAM available
- ✅ You want GitOps workflow experience

**NO (or wait), if:**
- ❌ Your machine has <16 GB RAM total
- ❌ You're still learning OKD basics
- ❌ You only plan to use one cluster
- ❌ You prefer OpenShift native tools

**Recommendation for you:** **YES!** ✅  
You have experience, want to learn Rancher, and likely have the hardware. Start with Docker method, import OKD, and explore. If it's useful, upgrade to production setup later.

---

**Ready to proceed?** Let me know and I'll help you install Rancher and import your OKD cluster! 🚀

---

**Last Updated:** 2026-03-05  
**Maintained by:** Helpful Bob 🤖
