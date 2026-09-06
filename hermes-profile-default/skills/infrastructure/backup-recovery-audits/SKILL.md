---
name: backup-recovery-audits
description: "Use when auditing live backup paths and restore readiness."
version: 1.0.0
created_by: agent
---

# Backup & Recovery Audits

Use when Avi needs an evidence-only answer about what is backed up, where it goes, whether it is off-box, and what survives total machine loss. This is a read-only audit skill: do not run backup jobs, mutate repositories, or trigger provider recovery checks unless explicitly asked.

## Evidence standard

Label every conclusion exactly as one of:

- **LIVE-VERIFIED** — observed from the current system, active scheduler, live service, mounted storage, or repository metadata.
- **DOCUMENTED** — stated in local documentation but not independently proven in this audit.
- **INFERRED** — a bounded conclusion from observed implementation; state the assumption.
- **STALE/CONFLICTING** — documentation and live evidence disagree; name both.
- **UNRESOLVED** — inaccessible or not proven. Do not convert absence of local evidence into proof that a provider-side snapshot does not exist.

Do not expose credential contents, tokens, private keys, database contents, or repository secrets. Paths, service names, remote hostnames, repository URLs, timestamps, sizes, and non-secret configuration behavior are appropriate evidence.

## Audit workflow

1. **Identify systems and access boundary.** Record each host’s hostname and its confirmed connectivity path. Keep a clear distinction between the machine under audit and an external provider/control plane that was not accessed.
2. **Inventory scheduling at every layer.** Check user/root crontabs, systemd timers and custom services, application schedulers, and each Hermes default/named-profile scheduler. Jobs with the same display name may be separate jobs in separate profile contexts.
3. **Read the executable implementation.** For each actual backup job, capture its script path, source, staging destination, remote destination, exclusions, lock behavior, and last persisted output. Do not rely on comments or a README alone.
4. **Verify off-box mechanisms.** Inspect configured Git remotes, installed/configured backup tools (for example rclone/restic/borg), scheduled rsync paths, remote mounts, and active processes. Report the precise scope checked for a negative finding.
5. **Inventory stateful data separately.** Treat source code, configuration, credentials, operational files, database volumes, application data, and vaults as separate recovery components. A Git remote for upstream source code does not back up local databases or deployment configuration.
6. **Assess restore readiness.** A configured destination or a job output that says "pushed" establishes configured/reported execution—not a restore-proven recovery path. Mark recovery as unproven until remote retrieval or a restore drill is verified.
7. **Report exact restoration gaps.** For a total-loss scenario, name the local-only paths and the manual reconstruction steps required, while keeping unverified external credential stores and provider backups explicitly unresolved.

## Hermes-specific checks

- Inspect both `hermes cron list` and `hermes --profile <name> cron list` for every relevant profile.
- A default Hermes home and a named profile are distinct backup sources. Confirm each script’s source and exclusions; do not infer origin from a repository subdirectory name.
- Default-home backups may exclude `profiles/`, while a named-profile backup may target only one profile. State that coverage boundary plainly.
- Compare displayed scheduler times with commit timestamps and script timestamp formatting. If a README’s stated timezone disagrees with live scheduler output, label it **STALE/CONFLICTING**.

## Reporting format

End with:

| Component | Backup destination | Frequency | Off-box? | Restore-ready? | Evidence |
|---|---|---:|---|---|---|

Use `No verified path` rather than `No` when the audit did not access a possible provider control plane. Use `Partial; unproven` for a backup that excludes credentials, state, or data and has not undergone a restore drill.

## Pitfalls

- Never invoke a scheduled backup merely to learn what it does; read its script and retained job output.
- Do not confuse local backup archives with off-box protection. They are useful only while the host storage remains recoverable.
- Do not claim a private repository, successful remote push, provider snapshot, or remote-sync recovery unless that specific fact was verified.
- Avoid broad content scans that produce noisy false positives from binaries, vendored code, or generic documentation. Prefer configuration locations, executable inventory, scheduler definitions, mount data, and targeted script inspection.
