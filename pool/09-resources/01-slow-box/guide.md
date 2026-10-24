# Slow Box

## TICKET
Users report a sluggish box; the thumbnail job repeatedly dies. Investigate before changing workloads.
1. Save load averages, a memory summary explaining "available," and the top five CPU and memory consumers in `~/slow-report.txt`. Label each view; host-wide CPU and RAM totals are not the container's limits.
2. Identify the service consuming CPU. Lower its priority without stopping its required work, prove the effective priority and make the change persistent in its unit.
3. Record the thumbnail service's failure result, restart count and configured memory limit.
4. Increase its memory allowance enough to finish and ensure successful completion does not restart it. Verify completion in logs and that the restart count stops increasing.

## COMMANDS
uptime free top ps nice renice systemctl journalctl

## QUESTIONS
1. `free` shows little memory as free but much more as available. What does
   available estimate, and why can reclaimable cache make those figures differ?
2. What does the OOM killer do, how does it choose a victim, and how does a
   cgroup memory-limit OOM differ from a whole-machine OOM? Where can you find
   evidence after the event?
3. A system has high load but low CPU use. What kinds of work can contribute
   to load, and how would runnable and uninterruptible process states help
   distinguish CPU contention from waiting on I/O?
4. When should an operator kill, renice or limit a process? What does each
   choice trade away, and why is killing a job that must finish the wrong fix?

## ANSWERS