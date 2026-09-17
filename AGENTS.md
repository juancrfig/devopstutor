# AGENTS.md — devops_gym

Single shared Docker container for all DevOps/Linux gym tickets. Fresh build per
session; `--rm` so no state persists between runs. Juanes opens the container
himself — agents only write guides and setup.sh broken states.

## Structure

```
devops_gym/
├── Dockerfile       ← ubuntu:24.04, user juanes (NOPASSWD sudo)
├── setup.sh         ← fabricates broken state; grows as tickets are added
├── run.sh           ← docker build + docker run --rm -it --hostname devops-lab
├── gym              ← TUI launcher; Leitner scheduling in .gym-ledger
└── pool/
    └── <topic>/<scenario>/guide.md
```

## Container decisions (settled)

- One container, all topics. Base: `ubuntu:24.04`.
- Fresh build per session (`./run.sh` always rebuilds). `--rm` wipes on exit.
- No `check.sh` — concept questions go to Claude post-solve.
- `setup.sh` is one growing file. Refactor only when it hurts.
- Juanes opens the container himself; the `gym` TUI serves guides separately.
- Scheduling lives in `.gym-ledger` (Leitner, managed by `gym`). No external
  ledger — the old vault ledger is retired.
- Live incident processes (log flooder, zombie, respawner, traffic writer)
  are started by a guarded block in `/etc/bash.bashrc` at first shell.

## Adding a ticket

1. `pool/<topic>/<scenario>/guide.md` — follow the format below.
2. Add broken state to `setup.sh`.
3. `./run.sh` — verify the broken state lands correctly.

## guide.md format (parsed by `gym`)

```markdown
# <title>
## TICKET
<symptom — NEVER names a command>
## COMMANDS
cmd1 cmd2 cmd3
## QUESTIONS
1. <interview-style concept question>
```

## Design rules

- Never name the command in the ticket. Symptoms only.
- Storm realism: tickets are incident scenarios, not drills. Multi-command
  solutions; force pipes, globbing, and redirection (`>`, `>>`, `2>`, `2>&1`).
- QUESTIONS: ~3–5 genuine mid-level DevOps interview
  questions probing fundamentals. No trivia.
- `setup.sh` should itself be good shell-scripting practice to read post-solve.

## Command inventory by topic

| Topic | Commands | Tickets |
|---|---|---|
| 01-orientation | whoami who w hostname uname uptime date free lscpu history command -v cat echo | 01-amnesia-shift |
| 02-files | ls find file stat wc du df touch rm | 01-disk-bloat, 02-mystery-artifacts |
| 03-text | cat head tail grep sort cut tr xargs wc echo | 01-log-triage, 02-csv-rescue |
| 04-users-perms | groups adduser deluser chmod chown chgrp su usermod id find ls stat | 01-offboard-onboard, 02-perm-meltdown |
| 05-processes | ps pgrep kill fg bg pstree | 01-log-flood, 02-immortal-daemon |
| 06-services | systemctl journalctl — **parked**: plain container has no systemd PID 1. Unpark plan: systemd-as-PID-1 image run with `--cgroupns=host -v /sys/fs/cgroup:/sys/fs/cgroup` (or podman). Until then, systemd theory rides in 05-processes questions. | — |

## Planned topics (near future)

Missing for mid-level interview coverage; next expansion wave:

- **networking** — ss, curl, dig, ports, "service can't reach DB" scenarios
- **ssh** — keys, scp, config, agent
- **systemd** — hands-on units (unparks 06-services via the plan above)
- **junior-gauntlet** — **[design by 2026-08-13]** Combo incident: SSH into a wild server with multiple simultaneous issues — zombie processes, missing services, unusual memory usage, and dangerously high load averages. Mimics a real-world demanding scenario. Junior DevOps rite of passage. Mixes processes, files, text, and perms tools in one ticket.
