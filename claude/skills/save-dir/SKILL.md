---
name: s
description: Save the current working directory to ~/.var/zsh/.saved_dir so that the shell's `i` function can restore it. Use when the user types /s or asks to save the current directory.
user_invocable: true
allowedTools:
  - Bash(pwd | tee ~/.var/zsh/.saved_dir > /dev/null)
---

# Save Current Directory

Save the current working directory to the zsh saved-dir file, mirroring the shell's `s()` function.

## Steps

Run the following command using the Bash tool:

```bash
pwd | tee ~/.var/zsh/.saved_dir > /dev/null
```

Then confirm to the user which directory was saved.
