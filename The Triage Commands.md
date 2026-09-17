# Triage Commands

A growing collection of one-shot triage pipelines for incident response. Each entry is: what you type, what it tells you, and when to use it.

---

## 1. `ps aux --sort=-%cpu | head -10`

**What it does:** Shows the top 10 CPU-hungry processes on the box, sorted heaviest first.

**Column cheat sheet:**

| Column | What it is |
|---|---|
| `USER` | Who owns the process |
| `PID` | Process ID — needed to kill it |
| `%CPU` | CPU usage percentage |
| `%MEM` | Memory usage percentage |
| `RSS` | Physical memory in use (KB) — the real memory footprint |
| `STAT` | Process state: `R` (running), `S` (sleeping), `Z` (zombie) |
| `COMMAND` | The actual program + its arguments |

**When to use:** First thing when a server feels slow or load is high. Tells you who's eating the CPU in one command.

**Variations:**

```bash
# Top memory consumers
ps aux --sort=-%mem | head -10

# Full process list, grep for something
ps aux | grep nginx

# Count processes by name
ps aux | grep -c apache

# Show only PID and command (cleaner)
ps -eo pid,%cpu,%mem,comm --sort=-%cpu | head -10
```

---

*(more triage commands added here as you learn them)*