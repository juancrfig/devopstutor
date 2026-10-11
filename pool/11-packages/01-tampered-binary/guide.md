# Tampered Binary

## TICKET

A runbook says a utility is installed, but the command still cannot be found. At the same time, security suspects a package-owned program was replaced. This lab needs internet access: the package index is empty when the session starts.

1. Diagnose the missing utility. A stale copy sits in `/opt/tools/bin`, which is not on your normal search path. Install the distro package, then record the utility's version and the repository it came from.
2. Check installed package files. Ignore missing documentation and modified configuration files; exactly one non-configuration file is modified. Identify its owning package, reinstall only that package, and verify that file is clean.
3. Hold the `less` package at its current version. Prove the hold using the package manager's simulated upgrade; if the current repository has no newer `less` version, show the hold list and state that the simulation had no upgrade to skip.
4. Remove the `cron` package and record its package state and remaining configuration file. Then purge it and show that the configuration file is gone.

## COMMANDS
apt update install install --reinstall remove purge show policy apt-get -s upgrade dpkg -S -L -l --verify apt-mark hold showhold command -v ls grep tee

## QUESTIONS
1. What work does the high-level package manager do that the low-level package tool does not? What changes when you refresh package indexes versus upgrade installed software?
2. How do signed repository metadata and package signatures establish trust? What new risks come with adding an untrusted repository?
3. Why can a package removal leave configuration behind, and what additional state does purging remove?
4. Why might an operator hold a package temporarily, and what security or reliability risk comes from leaving it held indefinitely?

## ANSWERS
