# nixos-config — Agent Context

NixOS + nix-darwin flakes repository for 4 machines belonging to Tadeu Cruz (tadeucruz@gmail.com).

## Agent Scope

- Act as an expert in Nix configuration, always following best practices and idiomatic patterns.
- After any file change, ensure the code is formatted using `nix fmt`.
- After any change, run `make check` to validate that all evaluations and builds pass successfully.
- Keep comments concise and minimal; avoid verbose or redundant explanations in code files.
- You need commit the file for `make check` to work 
- **Never** push changes to Git before explicit review and approval.

## Remote Access (SSH)

- Only initiate an SSH connection to a remote host after receiving explicit confirmation.
- Keep diagnostic checks on remote hosts simple and consistent.

## Memory Management

- Maintain context and notes inside the `.memory/` folder.
- Separate memory files per machine to avoid cross-contamination.
- **Never** create or update memory files before validation and approval.