# Local Setup Guide

Complete walkthrough to get Jenkins running locally and executing the pipeline end-to-end.

---

## Prerequisites

| Tool | Version | Verify |
|---|---|---|
| Docker Desktop | Latest | `docker --version` |
| PowerShell | 7+ | `pwsh --version` |
| Git | Any | `git --version` |

Docker Desktop must be **running** before proceeding (check the system tray icon).

---

## Step 1 — Clone the repo

```bash
git clone https://github.com/YOURUSERNAME/ps-deployment-toolkit.git
cd ps-deployment-toolkit
```

---

## Step 2 — Start Jenkins in Docker

```bash
docker compose up -d
```

This pulls `jenkins/jenkins:lts-jdk17` and starts the container on port 8080.
A named volume `jenkins_home` persists all Jenkins config between restarts.

Verify the container is running:
```bash
docker ps
```

Expected output includes a row with `jenkins-ci` and `Up`.

Wait about 60 seconds for Jenkins to finish its initial boot.

---

## Step 3 — Unlock Jenkins

Get the one-time admin password:
```bash
docker exec jenkins-ci cat /var/jenkins_home/secrets/initialAdminPassword
```

Open **http://localhost:8080** in your browser, paste the password, and click Continue.

---

## Step 4 — Install plugins

- Select **Install suggested plugins** and wait (~5 minutes)
- After installation completes, create your admin account
- Keep the Jenkins URL as `http://localhost:8080`
- Click **Save and Finish** → **Start using Jenkins**

Then install the PowerShell plugin:
- **Manage Jenkins** → **Plugins** → **Available plugins**
- Search: `PowerShell`
- Check **PowerShell Plugin** → **Install**
- Allow Jenkins to restart

---

## Step 5 — Create the pipeline job

1. Jenkins dashboard → **New Item**
2. Name: `ps-deployment-toolkit`
3. Select **Pipeline** → **OK**
4. Under **Pipeline** section:
   - Definition: `Pipeline script from SCM`
   - SCM: `Git`
   - Repository URL: `https://github.com/YOURUSERNAME/ps-deployment-toolkit.git`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
5. **Save**

---

## Step 6 — Run the pipeline

Click **Build Now**.

The Stage View will show each stage lighting up in sequence:

```
Checkout → Validate → Build → [Test: Deploy | Test: Baseline] → Package → Report
```

All stages green = success. Click any stage box to view its console output.

---

## Step 7 — View artifacts

After a successful build:
- Click the build number (e.g., `#1`) in the left sidebar
- Click **Artifacts**
- You'll see `ps-deployment-toolkit-1.0.1.zip` and the baseline JSON files

---

## Stopping Jenkins

```bash
docker compose down
```

Data persists in the `jenkins_home` Docker volume. To fully reset:
```bash
docker compose down -v
```

---

## Troubleshooting

**Port 8080 already in use**
Change the port mapping in `docker-compose.yml`:
```yaml
ports:
  - "8090:8080"
```
Then access Jenkins at http://localhost:8090.

**PowerShell step fails with "pwsh not found"**
The Jenkins container runs Linux. Install PowerShell in the container or use a custom Docker agent image with PowerShell pre-installed. See `docs/pipeline-stages.md` for the agent image approach.

**Build fails at Package stage on Windows Jenkins agent**
The `Compress-Archive` path resolution differs on Windows vs Linux. Ensure Jenkins agent OS matches the path syntax in the Jenkinsfile `powershell` blocks.
