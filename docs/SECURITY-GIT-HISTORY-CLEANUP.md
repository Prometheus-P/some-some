# Git History Cleanup Guide - Removing Sensitive Data

## Overview

This document describes how to remove sensitive data (API keys, passwords, credentials) from Git history when accidentally committed.

**CRITICAL**: Once sensitive data is pushed to a public repository, consider it **compromised**. Always rotate credentials immediately, even after removing from history.

---

## Quick Assessment Checklist

Before proceeding, determine the severity:

| Scenario | Severity | Action |
|----------|----------|--------|
| Secret committed but NOT pushed | LOW | Use `git reset` |
| Secret pushed to private repo (no forks) | MEDIUM | Use `git filter-branch` or BFG |
| Secret pushed to public repo | CRITICAL | Rotate credentials + use BFG + contact GitHub |
| Secret in forked repositories | CRITICAL | Cannot remove from forks - ROTATE IMMEDIATELY |

---

## Method 1: Not Yet Pushed (Easiest)

If the sensitive data was committed but NOT pushed:

```bash
# Undo last commit, keep changes staged
git reset --soft HEAD~1

# Remove sensitive file from staging
git restore --staged <sensitive-file>

# Or amend the commit without the file
git commit --amend
```

---

## Method 2: BFG Repo-Cleaner (Recommended)

BFG is faster and simpler than `git filter-branch`.

### Installation

```bash
# macOS
brew install bfg

# Or download JAR directly
curl -L -o bfg.jar https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar
```

### Remove Specific Files

```bash
# Clone a fresh mirror (important!)
git clone --mirror git@github.com:YOUR-ORG/YOUR-REPO.git

# Remove specific file from ALL history
bfg --delete-files google-services.json YOUR-REPO.git

# Or remove files matching pattern
bfg --delete-files '*.jks' YOUR-REPO.git
bfg --delete-files '*.env' YOUR-REPO.git
```

### Remove Secrets from File Contents

Create a file `secrets.txt` with patterns to replace:

```text
# secrets.txt - one secret per line
AKIAIOSFODNN7EXAMPLE
wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

```bash
# Replace secrets with ***REMOVED***
bfg --replace-text secrets.txt YOUR-REPO.git
```

### Clean Up and Push

```bash
cd YOUR-REPO.git

# Clean unreferenced objects
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push ALL branches
git push --force --all
git push --force --tags
```

---

## Method 3: git filter-repo (Modern Alternative)

`git filter-repo` is the modern replacement for `git filter-branch`.

### Installation

```bash
# macOS
brew install git-filter-repo

# pip
pip install git-filter-repo
```

### Remove Files

```bash
# Remove specific file from history
git filter-repo --path google-services.json --invert-paths

# Remove multiple files
git filter-repo --path .env --path secrets.json --invert-paths

# Remove by pattern (glob)
git filter-repo --path-glob '*.jks' --invert-paths
```

### Replace Text Content

```bash
# Create expressions file
echo 'AKIAIOSFODNN7EXAMPLE==>***REMOVED***' > expressions.txt

git filter-repo --replace-text expressions.txt
```

---

## Method 4: git filter-branch (Legacy, Slow)

Only use if BFG and filter-repo are unavailable.

```bash
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch path/to/sensitive-file' \
  --prune-empty --tag-name-filter cat -- --all

# Clean up
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push
git push origin --force --all
git push origin --force --tags
```

---

## Post-Cleanup Actions

### 1. Notify Collaborators

All collaborators must:

```bash
# Option A: Fresh clone (recommended)
rm -rf local-repo
git clone <repo-url>

# Option B: Reset to remote
git fetch origin
git reset --hard origin/main
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

### 2. GitHub-Specific Actions

```bash
# Request GitHub garbage collection (removes from GitHub's cache)
# Contact GitHub Support for:
# - Removing cached views
# - Removing from search index
# - Removing from forks (not always possible)
```

### 3. Rotate All Compromised Credentials

| Type | Action |
|------|--------|
| AWS Keys | IAM Console → Deactivate old key → Create new key |
| Firebase | Firebase Console → Project Settings → Regenerate |
| GitHub Tokens | Settings → Developer Settings → Revoke + Create new |
| API Keys | Provider dashboard → Revoke + Create new |
| Signing Keys | Generate new keystore, update Play/App Store |

---

## Prevention Measures

### Pre-commit Hook

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Detect secrets before commit

PATTERNS=(
  'AKIA[0-9A-Z]{16}'           # AWS Access Key
  '[a-zA-Z0-9+/]{40}'          # Generic 40-char base64
  'ghp_[a-zA-Z0-9]{36}'        # GitHub Personal Token
  'sk-[a-zA-Z0-9]{48}'         # OpenAI API Key
  'AIza[0-9A-Za-z\\-_]{35}'    # Google API Key
)

for pattern in "${PATTERNS[@]}"; do
  if git diff --cached | grep -qE "$pattern"; then
    echo "ERROR: Potential secret detected matching pattern: $pattern"
    echo "Please remove before committing."
    exit 1
  fi
done
```

### git-secrets Tool

```bash
# Install
brew install git-secrets

# Setup for repository
cd your-repo
git secrets --install
git secrets --register-aws

# Add custom patterns
git secrets --add 'private_key'
git secrets --add --allowed 'fake-key-for-testing'
```

---

## Emergency Response Playbook

If secrets are exposed publicly:

1. **IMMEDIATELY** (within minutes):
   - Rotate/revoke the exposed credential
   - Check for unauthorized usage in provider logs

2. **Within 1 hour**:
   - Run BFG to remove from history
   - Force push to all branches
   - Contact GitHub Support if public repo

3. **Within 24 hours**:
   - Audit all access logs
   - Check for lateral movement
   - Update incident documentation
   - Notify affected parties if data breach

4. **Follow-up**:
   - Implement pre-commit hooks
   - Add secrets scanning to CI/CD
   - Team training on secure practices

---

## References

- [GitHub: Removing sensitive data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
- [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/)
- [git-filter-repo](https://github.com/newren/git-filter-repo)
- [git-secrets](https://github.com/awslabs/git-secrets)

---

**Last Updated**: 2025-12-03
**Document Owner**: Security Team
