# Tampered Binary

## TICKET
A utility mentioned in a runbook cannot be found; security suspects an installed program was altered. The package index begins empty and the lab needs internet access.
1. Diagnose the missing utility. A stale copy exists outside your normal search path at `/opt/tools/bin`. Install the distribution-managed package and record version and repository.
2. Audit installed package files, ignoring missing documentation and changed configuration. Find the one modified non-configuration file, identify its package, reinstall only that package and verify repair.
3. Hold `wget` at its current version. Prove the hold and inspect a simulated upgrade. If no newer version exists, state that the simulation could not demonstrate a skipped upgrade.
4. Remove `cron` while preserving configuration; record its state and remaining config file. Then purge configuration and verify it is gone.

## COMMANDS
apt update install install --reinstall remove purge show policy apt-get -s upgrade dpkg -S -L -l --verify apt-mark hold showhold command -v ls grep tee

## QUESTIONS
1. What work does the high-level package manager do that the low-level package tool does not? What changes when you refresh package indexes versus upgrade installed software?
2. How do signed repository metadata and package signatures establish trust? What new risks come with adding an untrusted repository?
3. Why can a package removal leave configuration behind, and what additional state does purging remove?
4. Why might an operator hold a package temporarily, and what security or reliability risk comes from leaving it held indefinitely?

## ANSWERS
