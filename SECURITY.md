# Security Policy

## Reporting a vulnerability

Do not disclose suspected vulnerabilities, credentials, tokens, or other sensitive information in a public GitHub issue.

Use GitHub private vulnerability reporting when it is enabled for this repository.

## Secrets policy

This repository must not contain:

- Kubernetes kubeconfig files
- Argo CD administrator passwords
- GitHub tokens
- Private SSH keys
- Environment files containing credentials
- Unencrypted Kubernetes Secret values
- Cloud-provider credentials

If a secret is committed, removing it in a later commit is not sufficient because it remains in Git history. The credential must be revoked and replaced.
