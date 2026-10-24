# Amnesia Shift

## TICKET
You are paged onto an unfamiliar server. The previous admin's handover note appears at login and claims the machine runs CentOS 7, has 64 cores and 128 GB RAM, has been up for over 400 days, and uses zsh for every user. It also claims the shared admin account has an unremarkable command history.

1. Verify each claim against the running system. Record the actual OS, architecture, CPU count, memory, uptime, and login-shell evidence, distinguishing observations from the handover's claims.
2. Review the command history available to your current account, which Dana also used. Identify any entries that warrant investigation and explain why, or explicitly report that none do.
3. Summarize the discrepancies and any follow-up risks. Do not change the machine while investigating.

## COMMANDS
uname uptime free lscpu cat command -v history

## QUESTIONS
1. Interview: `uptime` shows load average `12.0, 3.0, 0.5` on a 4-core machine. Walk me through what that tells you and what you'd look at next.
2. Interview: what's the difference between the kernel and the distribution? Where did each of your verification commands get its answer from?

## ANSWERS
