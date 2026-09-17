# Immortal Daemon

## TICKET
A rogue "watchdog" from a long-gone vendor is running on this box. Every
attempt the last admin made to stop it politely failed — it even mocks them
in `/var/log/watchdog.log`. Worse: on the one occasion it *did* die, it was
back seconds later, like nothing happened.

Take it down for good, and document the kill chain in `~/takedown.txt`:
1. Locate the watchdog and watch its log live while you send it the
   standard polite termination signal. Record what it does with it.
2. Explain in the report *how* a process can survive that signal — and
   name the one signal no process can ignore. Use it. Record what happens
   in the seconds after.
3. It came back. Find out *why*: map the ancestry, identify its guardian,
   and decide the correct kill order to end the pair permanently.
4. Prove the box is clean: no watchdog, no guardian, log silent. Append
   the final evidence, including how you verified absence rather than
   presence.

## COMMANDS
ps pgrep pstree kill tail grep

## QUESTIONS
1. Interview: SIGTERM vs SIGKILL vs SIGHUP — what does each mean by convention, which can a process catch, and why do orchestrators (Docker, Kubernetes, systemd) always send one, wait, then send another?
2. Interview: why is `kill -9` as a first resort considered malpractice? Name two kinds of damage it can cause that SIGTERM wouldn't.
3. Interview: this respawn behavior is exactly what a supervisor like systemd provides on purpose. Explain what systemd is, what a unit is, and how `systemctl` + `journalctl` would have made this whole ticket a two-command job.
4. Interview: how would you stop a service supervised by systemd correctly, and why does killing the process directly not work there either?
