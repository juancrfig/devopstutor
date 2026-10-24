# Shop API Crash Loop

## TICKET
The `shop-api` service failed after deployment; a vendor-unit edit has not taken effect.
1. Save unit status and last 20 unit-specific log lines in `~/service-report.txt`.
2. Resolve all five failure causes, appending evidence of the next problem after each fix; do not stop at a briefly active service.
3. Restore the vendor unit from the pristine reference under `/var/lib/shop-api/`; keep local changes in an `/etc` override.
4. Enable boot startup and crash recovery, proving recovery with a new main PID after killing the old one.
5. Display current-boot error-level messages for this unit only.

## COMMANDS
systemctl status start stop restart enable is-enabled is-active cat edit daemon-reload show journalctl -u -b -p -n -f --since sudo chmod ls cat kill ps

## QUESTIONS
1. Trace a machine boot from firmware through the bootloader and kernel to systemd as PID 1, then explain how targets and unit dependencies lead to a service starting.
2. What state changes when a unit is started versus enabled? What does enabling install on disk, and why can an enabled service still fail at boot?
3. Which unit definition wins across `/lib/systemd/system`, `/etc/systemd/system`, and drop-ins? Why must the manager reload unit files, and how can an unreloaded on-disk edit be detected?
4. Where does journald keep a service's logs compared with classic `/var/log` files? How do you inspect the previous boot, and what must be configured for journal entries to survive a reboot?

## ANSWERS
