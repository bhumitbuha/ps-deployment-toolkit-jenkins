# ps-deployment-toolkit

A Jenkins CI pipeline for a small PowerShell tooling project. Jenkins runs in Docker and the whole pipeline lives in a Groovy `Jenkinsfile`.

## Pipeline Overview

```
Checkout > Validate > Build > Test (parallel) > Package > Report
```

| Stage | What happens |
|---|---|
| Checkout | Pulls source from GitHub via SCM |
| Validate | Asserts all required files exist before building |
| Build | Runs `Set-Baseline.ps1` to generate Dev and Staging config artifacts |
| Test | Runs `Test-Deploy.ps1` and `Test-Baseline.ps1` in parallel |
| Package | Zips source plus artifacts into a versioned bundle |
| Report | Prints artifact listing and build summary |

When the build passes, the artifacts get archived and fingerprinted in Jenkins.

## Project Structure

```
ps-deployment-toolkit/
├── .github/
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── ISSUE_TEMPLATE/
│       ├── bug_report.md
│       └── feature_request.md
├── docs/
│   ├── setup-guide.md
│   └── pipeline-stages.md
├── src/
│   ├── Deploy-Endpoint.ps1
│   └── Set-Baseline.ps1
├── tests/
│   ├── Test-Deploy.ps1
│   └── Test-Baseline.ps1
├── artifacts/
├── .gitignore
├── CHANGELOG.md
├── CONTRIBUTING.md
├── Jenkinsfile
├── docker-compose.yml
└── README.md
```

## Stack

Jenkins LTS (Groovy declarative pipeline), Docker and Docker Compose, PowerShell 7+, Git/GitHub.

## Quick Start

You'll need Docker Desktop running, PowerShell 7 or higher (`pwsh`), and Git.

### 1. Clone and start Jenkins

```bash
git clone https://github.com/bhumitbuha/ps-deployment-toolkit-jenkins.git
cd ps-deployment-toolkit-jenkins
docker compose up -d
```

Give it about a minute, then open http://localhost:8080.

### 2. Unlock Jenkins

```bash
docker exec jenkins-ci cat /var/jenkins_home/secrets/initialAdminPassword
```

Paste that into the browser.

### 3. Install plugins

Choose **Install suggested plugins**. After setup finishes, go to **Manage Jenkins > Plugins > Available** and install the **PowerShell Plugin**, then restart Jenkins.

### 4. Create the pipeline job

**New Item**, name it `ps-deployment-toolkit`, pick **Pipeline**, OK. Under Pipeline:

- Definition: Pipeline script from SCM
- SCM: Git
- Repository URL: your GitHub repo URL
- Branch: `*/main`
- Script Path: `Jenkinsfile`

Save, then click **Build Now**.

The full walkthrough lives in [docs/setup-guide.md](docs/setup-guide.md).

## Source Scripts

### `src/Deploy-Endpoint.ps1`

Simulates deploying a baseline configuration to a named endpoint. It runs four stages (validate baseline, validate params, apply config, write log) and exits 0 on success or 1 on failure.

```powershell
.\src\Deploy-Endpoint.ps1 -ComputerName "WORKSTATION-01" -BaselinePath ".\artifacts\baseline-dev.json"
```

Output is a structured JSON log written to `artifacts/deploy.log`.

### `src/Set-Baseline.ps1`

Generates a JSON baseline configuration file for a target environment.

```powershell
.\src\Set-Baseline.ps1 -OutputPath ".\artifacts\baseline-prod.json" -Environment Prod
```

Environments are `Dev` (7-day log retention), `Staging` (30-day), and `Prod` (90-day, auto-update on).

## Tests

The tests use a custom assertion pattern, so there's no external framework to install.

```powershell
pwsh tests/Test-Deploy.ps1
pwsh tests/Test-Baseline.ps1
```

| Suite | Tests | Covers |
|---|---|---|
| Test-Deploy.ps1 | 7 | File existence, param block, mandatory params, exit code, stage logging, log writing, live execution |
| Test-Baseline.ps1 | 5 | File existence, output creation, valid JSON, environment field, log retention value |

Both exit 0 on a clean pass and 1 if anything fails. The Jenkins pipeline fails the build if either suite returns non-zero.

## Git Flow

This project follows [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/).

```
main        (stable, tagged releases)
  └── develop (integration)
        ├── feature/*   (new work)
        ├── bugfix/*    (fixes)
        ├── release/*   (release prep)
        └── hotfix/*    (emergency patches on main)
```

Branch naming, commit format, and the PR checklist live in [CONTRIBUTING.md](CONTRIBUTING.md).

## Related Project

The **Deploy** stage of this pipeline is designed to trigger the companion Ansible deployment pipeline:

- **[devops-ansible-deploy](https://github.com/bhumitbuha/devops-ansible-deploy)**: Ansible role-based deployment pipeline that builds the Docker image, manages container lifecycle, and validates health endpoints.

Together these two repos demonstrate a full CI/CD pipeline: Jenkins handles build/test/package; Ansible handles deploy/verify/rollback.

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

MIT
