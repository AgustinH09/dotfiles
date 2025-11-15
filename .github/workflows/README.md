# GitHub Actions Workflows

## Security Scan Workflow

The `security-scan.yml` workflow provides comprehensive security scanning for this dotfiles repository.

### What It Does

The workflow runs multiple security checks:

#### 1. **Secret Scanning** 🔍
- **TruffleHog**: Scans for accidentally committed secrets and credentials
- **Gitleaks**: Detects hardcoded passwords, API keys, and tokens
- Both tools scan the entire repository and git history

#### 2. **Path Validation** 📁
- Checks for hardcoded absolute paths (e.g., `/home/chicha09`)
- Warns about portability issues
- Non-blocking (won't fail the build)

#### 3. **Encryption Verification** 🔐
- Ensures sensitive files are encrypted with Age (`.age` extension)
- Checks for unencrypted `.pem`, `.key`, `*token*`, `*secret*` files
- Scans for exposed API keys in code
- **Blocking**: Fails if unencrypted sensitive files are found

#### 4. **File Permissions** 🔒
- Lists all executable files
- Helps identify unexpected permission changes

#### 5. **Dependency Scanning** 📦
- Uses Trivy to scan for vulnerabilities in dependencies
- Checks configuration files and scripts
- Non-blocking (informational only)

#### 6. **Chezmoi Validation** ✅
- Validates `chezmoi.toml` configuration
- Ensures encryption is properly configured
- Verifies `.chezmoiignore` includes private keys

#### 7. **Git History Deep Scan** 🕵️
- Scans entire git history for accidentally committed secrets
- Checks for patterns like private keys, AWS keys, GitHub tokens
- Non-blocking (warns if found)

### When It Runs

The workflow triggers on:
- **Push** to `main`, `master`, or `develop` branches
- **Pull requests** to `main` or `master`
- **Schedule**: Weekly on Mondays at 9:00 AM UTC
- **Manual trigger**: Via GitHub Actions UI (workflow_dispatch)

### How to Use

#### Running Manually

1. Go to your repository on GitHub
2. Click "Actions" tab
3. Select "Security Scan" workflow
4. Click "Run workflow"

#### Viewing Results

- **Summary**: Check the workflow summary for a quick overview
- **SARIF Reports**: Security findings are uploaded to GitHub Security tab
- **Logs**: Detailed logs available in each job

#### Local Testing

You can run some checks locally before pushing:

```bash
# Install Gitleaks
brew install gitleaks  # macOS
# or
curl -sSfL https://github.com/gitleaks/gitleaks/releases/download/v8.18.1/gitleaks_8.18.1_linux_x64.tar.gz | tar -xz

# Run Gitleaks scan
gitleaks detect --source . --verbose

# Check for hardcoded paths
grep -r "/home/chicha09" --exclude-dir=".git" --exclude-dir=".tmux" --exclude="*.age" .

# Verify encrypted files
find . -type f \( -name "*.pem" -o -name "*.key" \) ! -name "*.age" ! -path "*/.git/*"
```

### Configuration

#### Gitleaks Configuration

The workflow uses `.gitleaks.toml` for custom rules:
- Ignores `.age` encrypted files
- Allows Age public recipient key
- Allows environment variable references
- Custom rules for dotfiles-specific patterns

#### Customizing the Workflow

Edit `.github/workflows/security-scan.yml` to:
- Change trigger conditions
- Add/remove scanning tools
- Adjust failure conditions
- Modify scan patterns

### Troubleshooting

#### False Positives

If a scan reports false positives:

1. **For Gitleaks**: Update `.gitleaks.toml` allowlist
2. **For TruffleHog**: Add to `.trufflehog.yml` (create if needed)
3. **For path warnings**: Use environment variables instead of hardcoded paths

#### Workflow Fails

Common reasons and fixes:

| Issue | Solution |
|-------|----------|
| Unencrypted sensitive file | Encrypt with Age: `age -r <recipient> -o file.age file` |
| Secret in git history | Use `git-filter-repo` or BFG Repo-Cleaner |
| Gitleaks false positive | Add to `.gitleaks.toml` allowlist |
| Chezmoi validation fails | Check `chezmoi.toml` syntax |

### Security Best Practices

1. **Never disable security checks** to make CI pass
2. **Review all findings** before dismissing as false positives
3. **Rotate compromised secrets** immediately
4. **Use Age encryption** for all sensitive files
5. **Keep scanning tools updated** (workflow uses latest versions)

### Additional Resources

- [Gitleaks Documentation](https://github.com/gitleaks/gitleaks)
- [TruffleHog Documentation](https://github.com/trufflesecurity/trufflehog)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [Age Encryption](https://github.com/FiloSottile/age)
- [Chezmoi Security](https://www.chezmoi.io/user-guide/encryption/)

### Support

If you encounter issues with the workflow:
1. Check the workflow logs for detailed error messages
2. Review this README for common solutions
3. Test locally using the commands above
4. Update scanning tool configurations as needed
