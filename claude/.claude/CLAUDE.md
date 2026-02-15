# Global Claude Code Instructions

## Security

- **Never commit secrets**: Before every commit, scan staged files for API keys, tokens, passwords, private keys, and credentials (e.g. `.env`, `*.token`, `*.pem`, `credentials.json`, `~/.ssh/*`). If any secret or sensitive value is detected, STOP and warn the user immediately — do NOT proceed with the commit.

## Python

- **Always use a virtual environment**: When working on a Python project, ensure a virtual environment exists (e.g. `venv/`). If one doesn't exist, create it before installing any packages.
- **Always maintain requirements.txt**: Keep a `requirements.txt` file with pinned dependencies. Update it whenever packages are added or removed.
