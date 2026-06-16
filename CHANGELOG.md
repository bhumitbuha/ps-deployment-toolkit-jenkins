# Changelog

All notable changes to this project will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-05-17

### Added
- `src/Deploy-Endpoint.ps1`: 4-stage baseline deployment script with JSON log output
- `src/Set-Baseline.ps1`: environment-specific baseline config generator (Dev / Staging / Prod)
- `tests/Test-Deploy.ps1`: 7-test assertion suite for Deploy-Endpoint.ps1
- `tests/Test-Baseline.ps1`: 5-test assertion suite for Set-Baseline.ps1
- `Jenkinsfile`: 6-stage Groovy declarative pipeline (Checkout, Validate, Build, Test, Package, Report)
- `docker-compose.yml`: Jenkins LTS in Docker with persistent volume
- `.gitignore`: excludes build artifacts, logs, and editor files
- `CONTRIBUTING.md`: branch strategy and PR workflow
- `docs/setup-guide.md`: full local setup walkthrough
- `docs/pipeline-stages.md`: stage-by-stage pipeline reference

---

## [Unreleased]

- GitHub Actions mirror pipeline
- Pester integration for PowerShell unit tests
- Slack/email notification in post block
- Multi-node Jenkins agent configuration
