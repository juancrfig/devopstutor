# Slow Box

## TICKET
Users report that the box has become sluggish, and last night's thumbnail job
"keeps dying for no reason." Find the evidence before changing either job.

1. Save a triage snapshot to `~/slow-report.txt`: the load average, the memory
   summary with an explanation of what **available** means, and the top five CPU
   and top five memory consumers. Do not draw conclusions from the box's total
   memory or CPU count; those figures belong to the host. The summary and
   process views may rank consumers differently, so make clear which view each
   list represents.
2. Find the service responsible for the CPU load. It is a real report that
   must finish, so lower its priority rather than stopping it. Prove the new
   nice value, then make that priority permanent in the unit.
3. Find why the thumbnail job keeps dying. Use the service manager's result,
   restart count and configured memory limit as evidence; record all three in
   `~/slow-report.txt`.
4. Raise the memory limit in an override to let the job finish. Also correct
   its restart policy so a successful completion stays stopped. Prove the
   completion in its log and show that the restart count no longer increases.

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