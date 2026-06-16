# Contributing

## Branch Strategy (Git Flow)

```
main          ← production-ready, tagged releases only
  └── develop ← integration branch, always deployable
        └── feature/*   ← new features, branched from develop
        └── bugfix/*    ← bug fixes, branched from develop
        └── release/*   ← release prep, branched from develop → merges to main + develop
        └── hotfix/*    ← emergency fixes, branched from main → merges to main + develop
```

### Branch naming

| Type    | Pattern                         | Example                          |
|---------|---------------------------------|----------------------------------|
| Feature | `feature/<short-description>`   | `feature/add-pester-tests`       |
| Bugfix  | `bugfix/<short-description>`    | `bugfix/fix-log-path-null`       |
| Release | `release/v<major>.<minor>.<patch>` | `release/v1.1.0`              |
| Hotfix  | `hotfix/<short-description>`    | `hotfix/fix-deploy-exit-code`    |

---

## Workflow

### Starting a new feature

```bash
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name
```

### Finishing a feature

```bash
git checkout develop
git merge --no-ff feature/your-feature-name
git push origin develop
git branch -d feature/your-feature-name
```

### Creating a release

```bash
git checkout develop
git checkout -b release/v1.1.0
# bump version, update CHANGELOG.md
git checkout main
git merge --no-ff release/v1.1.0
git tag -a v1.1.0 -m "Release v1.1.0"
git checkout develop
git merge --no-ff release/v1.1.0
git branch -d release/v1.1.0
```

### Emergency hotfix

```bash
git checkout main
git checkout -b hotfix/fix-description
# make fix
git checkout main
git merge --no-ff hotfix/fix-description
git tag -a v1.0.1 -m "Hotfix v1.0.1"
git checkout develop
git merge --no-ff hotfix/fix-description
git branch -d hotfix/fix-description
```

---

## Commit Message Format

```
<type>(<scope>): <short summary>

[optional body: explain WHY not WHAT]
```

**Types:** `feat`, `fix`, `test`, `docs`, `ci`, `refactor`, `chore`

**Examples:**
```
feat(src): add Prod environment to Set-Baseline.ps1
fix(tests): correct exit code assertion in Test-Deploy.ps1
ci(jenkins): add parallel test stage to Jenkinsfile
docs(readme): add pipeline stage diagram
```

---

## Pull Request Checklist

- [ ] Branch is up to date with `develop`
- [ ] All tests pass locally (`pwsh tests/Test-Deploy.ps1`, `pwsh tests/Test-Baseline.ps1`)
- [ ] CHANGELOG.md updated under `[Unreleased]`
- [ ] No `.log` or `.json` artifact files committed
- [ ] PR title follows commit message format
