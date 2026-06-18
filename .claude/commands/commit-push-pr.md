---
allowed-tools: Bash(git checkout --branch:*), Bash(git add:*), Bash(git status:*), Bash(git push:*), Bash(git commit:*), Bash(gh pr create:*)
description: Commit, push, and open a PR
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`

## Your task

Based on the above changes:

1. Create a new branch if on dev (HEAD) or master
2. Create a single commit with an appropriate message
3. Push the branch to origin
4. Create a pull request using `gh pr create` with the appropriate title and description
5. Make sure the PR description is clear and concise. Skip the test plan part unless it is explicitly requested.
6. Never include any Claude attribution or "Generated with Claude Code" footer in the PR description.
7. You have the capability to call multiple tools in a single response. You MUST do all of the above in a single message. Do not use any other tools or do anything else. Do not send any other text or messages besides these tool calls.
8. When changes are requested to the current PR you should not create a new commit automatically. you should only create a new commit if it is explicitly requested.
