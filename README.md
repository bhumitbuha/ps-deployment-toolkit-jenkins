# ps-deployment-toolkit

A multi-stage Jenkins CI pipeline that automates build, test, and packaging for a PowerShell infrastructure tooling project. Jenkins runs in Docker; the pipeline is defined entirely in a Groovy `Jenkinsfile`.

---

## Pipeline Overview

```
Checkout → Validate → Build → Test (parallel) → Package → Report
```

| Stage | What happens |
|---|---|
| **Checkout** | Pulls source from GitHub via SCM |
| **Validate** | Asserts all required files exist before building |
| **Build** | Runs `Set-Baseline.ps1` to generate Dev and Staging config artifacts |
| **Test** | Runs `Test-Deploy.ps1` and `Test-Baseline.ps1` in parallel |
| **Package** | Zips source + artifacts into a versioned bundle |
| **Report** | Prints artifact listing and build summary |

On success, all artifacts are archived and fingerprinted in Jenkins.

---

## Project Structure

```
ps-deployment-toolkit/
├── .github/
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── ISSUE_TEMPLATE/
│       ├── bug_report.md
│       └── feature_request.md
├── docs/
│   ├── setup-guide.md          # Full local setup walkthrough
│   └── pipeline-stages.md      # Stage-by-stage pipeline reference
├── src/
│   ├── Deploy-Endpoint.ps1     # 4-stage deployment script with JSON log output
│   └── Set-Baseline.ps1        # Environment-specific baseline config generator
├── tests/
│   ├── Test-Deploy.ps1         # 7-test assertion suite
│   └── Test-Baseline.ps1       # 5-test assertion suite
├── artifacts/                  # Jenkins writes build outputs here (gitignored)
├── .gitignore
├── CHANGELOG.md
├── CONTRIBUTING.md
├── Jenkinsfile                 # Groovy declarative pipeline
├── docker-compose.yml          # Jenkins LTS in Docker on port 8080
└── README.md
```

---

## Stack

| Layer | Technology |
|---|---|
| CI Server | Jenkins LTS (Groovy declarative pipeline) |
| Container | Docker / Docker Compose |
| Scripting | PowerShell 7+ |
| SCM | Git / GitHub |

---

## Quick Start

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running
- [PowerShell 7+](https://github.com/PowerShell/PowerShell) (`pwsh`)
- Git

### 1. Clone and start Jenkins

```bash
git clone https://github.com/YOURUSERNAME/ps-deployment-toolkit.git
cd ps-deployment-toolkit
docker compose up -d
```

Wait ~60 seconds, then open **http://localhost:8080**.

### 2. Unlock Jenkins

```bash
docker exec jenkins-ci cat /var/jenkins_home/secrets/initialAdminPassword
```

Paste the password into the browser UI.

### 3. Install plugins

- Choose **Install suggested plugins**
- After setup, go to **Manage Jenkins → Plugins → Available**
- Search and install: **PowerShell Plugin**
- Restart Jenkins

### 4. Create the pipeline job

- **New Item** → name it `ps-deployment-toolkit` → choose **Pipeline** → OK
- Under Pipeline:
  - Definition: `Pipeline script from SCM`
  - SCM: `Git`
  - Repository URL: your GitHub repo URL
  - Branch: `*/main`
  - Script Path: `Jenkinsfile`
- **Save** → **Build Now**

See [docs/setup-guide.md](docs/setup-guide.md) for the full walkthrough.

---

## Source Scripts

### `src/Deploy-Endpoint.ps1`

Simulates deploying a baseline configuration to a named endpoint. Runs four internal stages (validate baseline, validate params, apply config, write log) and exits 0 on success or 1 on failure.

```powershell
# Usage
.\src\Deploy-Endpoint.ps1 -ComputerName "WORKSTATION-01" -BaselinePath ".\artifacts\baseline-dev.json"
```

**Output:** Structured JSON log written to `artifacts/deploy.log`.

### `src/Set-Baseline.ps1`

Generates a JSON baseline configuration file for a target environment.

```powershell
# Usage
.\src\Set-Baseline.ps1 -OutputPath ".\artifacts\baseline-prod.json" -Environment Prod
```

**Environments:** `Dev` (7-day log retention), `Staging` (30-day), `Prod` (90-day, auto-update on).

---

## Tests

Tests use a custom assertion pattern (no external framework required).

```powershell
# Run locally
pwsh tests/Test-Deploy.ps1
pwsh tests/Test-Baseline.ps1
```

| Suite | Tests | What it covers |
|---|---|---|
| Test-Deploy.ps1 | 7 | File existence, param block, mandatory params, exit code, stage logging, log writing, live execution |
| Test-Baseline.ps1 | 5 | File existence, output creation, valid JSON, environment field, log retention value |

Both suites exit 0 on full pass, 1 on any failure. The Jenkins pipeline fails the build if either suite returns non-zero.

---

## Git Flow

This project uses [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/).

```
main        ← stable, tagged releases
  └── develop ← integration
        ├── feature/*   ← new work
        ├── bugfix/*    ← fixes
        ├── release/*   ← release prep
        └── hotfix/*    ← emergency patches on main
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for branch naming, commit message format, and PR checklist.

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

---

## License

MIT
