# Pipeline Stages Reference

Detailed breakdown of every stage in the `Jenkinsfile`.

---

## Stage Map

```
┌─────────────┐
│  Checkout   │  Pulls source from SCM
└──────┬──────┘
       │
┌──────▼──────┐
│  Validate   │  Asserts all required files exist
└──────┬──────┘
       │
┌──────▼──────┐
│    Build    │  Generates baseline-dev.json + baseline-staging.json
└──────┬──────┘
       │
┌──────▼──────────────────────────────┐
│  Test (parallel)                     │
│  ┌───────────────┐ ┌───────────────┐ │
│  │ Test: Deploy  │ │ Test: Baseline│ │
│  └───────────────┘ └───────────────┘ │
└──────┬──────────────────────────────┘
       │
┌──────▼──────┐
│   Package   │  Zips src + artifacts into versioned bundle
└──────┬──────┘
       │
┌──────▼──────┐
│   Report    │  Prints artifact listing + build summary
└──────┬──────┘
       │
┌──────▼──────────────────────┐
│  post { success / failure } │  Archives artifacts or logs failure
└─────────────────────────────┘
```

---

## Stage: Checkout

**Purpose:** Pull the latest source from the configured SCM branch.

**Key behavior:**
- `checkout scm` uses the pipeline job's SCM configuration — no hardcoded repo URL in the Jenkinsfile
- Logs the Git branch and computed build version (`1.0.<BUILD_NUMBER>`)

**Fails if:** SCM is unreachable or credentials are missing.

---

## Stage: Validate

**Purpose:** Assert structural integrity before spending time on the build.

**Checks:**
- `src/Deploy-Endpoint.ps1` exists
- `src/Set-Baseline.ps1` exists
- `tests/Test-Deploy.ps1` exists
- `tests/Test-Baseline.ps1` exists

**Fails if:** Any file is missing — pipeline aborts immediately with a clear error message.

**Why validate before build:** Catches broken merges (e.g., accidental file deletion) before the slower build/test stages run.

---

## Stage: Build

**Purpose:** Execute the source scripts to produce build-time artifacts.

**Produces:**
- `artifacts/baseline-dev.json` — Dev environment baseline config
- `artifacts/baseline-staging.json` — Staging environment baseline config

**How it works:** Calls `Set-Baseline.ps1` twice with different `-Environment` values. The script generates JSON with environment-specific settings (firewall rules, log retention days, auto-update flag).

**Fails if:** `Set-Baseline.ps1` exits non-zero or PowerShell throws an unhandled exception.

---

## Stage: Test (parallel)

Two test suites run simultaneously using Groovy's `parallel` block.

### Test: Deploy Script

Runs `tests/Test-Deploy.ps1` which executes 7 assertions:

| # | Assertion |
|---|---|
| 1 | `Deploy-Endpoint.ps1` file exists |
| 2 | Script contains a `param()` block |
| 3 | Script has `[Parameter(Mandatory)]` |
| 4 | Script implements `ExitCode` tracking |
| 5 | Script uses stage-based logging (`[STAGE N]`) |
| 6 | Script writes output via `Out-File` |
| 7 | Script exits 0 with valid inputs (live execution) |

### Test: Baseline Script

Runs `tests/Test-Baseline.ps1` which executes 5 assertions:

| # | Assertion |
|---|---|
| 1 | `Set-Baseline.ps1` file exists |
| 2 | Running the script creates the output file |
| 3 | Output is valid JSON |
| 4 | `Environment` field equals `"Dev"` |
| 5 | `Settings.LogRetentionDays` equals `7` for Dev |

**Fails if:** Either test suite exits non-zero. Both must pass.

---

## Stage: Package

**Purpose:** Bundle source and artifacts into a versioned ZIP for distribution.

**Produces:** `artifacts/ps-deployment-toolkit-1.0.<BUILD_NUMBER>.zip`

**Contains:** All files from `src/` and `artifacts/` (baselines, logs).

**Why version the package:** Enables artifact traceability — each build produces a uniquely named ZIP that can be pinned and rolled back to.

---

## Stage: Report

**Purpose:** Print a human-readable summary of what was produced.

**Outputs:** Artifact directory listing with file sizes and timestamps.

---

## post block

| Condition | Action |
|---|---|
| `success` | `archiveArtifacts artifacts: 'artifacts/**/*'` — stores all artifacts in Jenkins |
| `failure` | Logs a failure message with a pointer to check stage logs |
| `always` | Logs the final build result regardless of outcome |

Archived artifacts are accessible from the build page under **Artifacts** and are fingerprinted for traceability.
