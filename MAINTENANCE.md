# Maintenance

The Ask Alteryx team owns ongoing maintenance for this repository.

## Regular Review

Maintainers should review the repository at least quarterly and before each
public release for:

- Stale documentation, examples, plugin metadata, installation commands, and
  support links.
- Vulnerable or deprecated dependencies, libraries, scripts, and generated
  assets.
- Unsafe defaults, insecure examples, misleading claims, or unclear security
  boundaries.
- Public issues and pull requests that require triage, escalation, or closure.
- Branding, trademark, and official-repository trust risks.

## Public-Safety Review

Before publication or release, maintainers should check tracked content and
repository history for:

- Credentials, passwords, API keys, tokens, private certificates, and secrets.
- Customer data, personal data, regulated data, proprietary workflows, and
  operational logs.
- Confidential Alteryx information, internal-only documentation, internal ticket
  references, unpublished roadmap material, and proprietary architecture
  details.
- Unreviewed screenshots, images, generated files, or third-party content.

Working-tree searches are not enough to prove history is clean. Review commit
history before launch or before moving a repository from an internal remote to
a public remote.

## Vulnerability Maintenance

Security reports should follow SECURITY.md. Maintainers should coordinate with
Alteryx Security on triage, remediation, disclosure timing, and any incident
response needs.
