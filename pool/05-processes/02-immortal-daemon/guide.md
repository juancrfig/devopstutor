# Immortal Daemon

## TICKET
A retired watchdog ignores polite termination and returns after being killed; its log is `/var/log/watchdog.log`. Document in `~/takedown.txt`.
1. Identify it, observe its log while requesting normal termination and record the response.
2. Explain how it can ignore that signal; force termination with an uncatchable signal and record what follows.
3. Find the process that restores it and stop the pair in an order that prevents respawning.
4. Prove both processes are absent and the log stays quiet.

## COMMANDS
ps pgrep pstree kill tail grep

## QUESTIONS
1. Interview: SIGTERM vs SIGKILL vs SIGHUP — what does each mean by convention, which can a process catch, and why do orchestrators (Docker, Kubernetes, systemd) always send one, wait, then send another?
2. Interview: why is `kill -9` as a first resort considered malpractice? Name two kinds of damage it can cause that SIGTERM wouldn't.
3. Interview: what does `fork` create, and how does a process replace its program image with `exec` while keeping the same PID?
4. Interview: when a process receives a signal while blocked in a system call, when can the handler run, and what does the interrupted call's return value tell you?

## ANSWERS
