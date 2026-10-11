# Shop API Crash Loop

## TICKET
After last night's deploy, `shop-api` is down. A teammate "fixed" the vendor unit file, but the change has not taken effect. Bring the API back safely:
1. Find what failed on this box. Save the unit's status and its last 20 log lines for this unit only to `~/service-report.txt`.
2. Fix each cause in turn. After every fix, capture the log line that proves the next failure in `~/service-report.txt`. There are five causes; don't stop when the unit first becomes active.
3. Put durable unit changes in an `/etc` override, not the vendor file. Revert the teammate's vendor edit using the pristine copy and note under `/var/lib/shop-api/` as your reference.
4. Make the service start at boot and recover after a crash. Prove recovery by killing its main process and showing that a new PID is active.
5. Show only this unit's error-level messages from the current boot.

## COMMANDS
systemctl status start stop restart enable is-enabled is-active cat edit daemon-reload show journalctl -u -b -p -n -f --since sudo chmod ls cat kill ps

## QUESTIONS
1. Trace a machine boot from firmware through the bootloader and kernel to systemd as PID 1, then explain how targets and unit dependencies lead to a service starting.
2. What state changes when a unit is started versus enabled? What does enabling install on disk, and why can an enabled service still fail at boot?
3. Which unit definition wins across `/lib/systemd/system`, `/etc/systemd/system`, and drop-ins? Why must the manager reload unit files, and how can an unreloaded on-disk edit be detected?
4. Where does journald keep a service's logs compared with classic `/var/log` files? How do you inspect the previous boot, and what must be configured for journal entries to survive a reboot?

## ANSWERS
