#!/usr/bin/python3
"""PreToolUse guard for Bash: force a permission prompt for dangerous commands.

Matches the command text itself, so it sees through env/uv wrappers, && chains, and heredocs
that prefix-based permission rules miss. That catches honest mistakes, not deliberate
obfuscation. Credential scoping is the real backstop.

Pinned to the system python3 (3.9) so it runs the same regardless of which venv is active.
Any error exits 0 without a decision: a broken guard must not block every Bash call.
"""

import json
import re
import sys

MODAL_DEV_ENV = "dev-ryan"

# Checked against each command in a chain separately, so a flag in one command can't
# implicate its neighbour (e.g. `git push && grep -f x`).
SEGMENT_RULES = [
    (r"\bterraform\s+(apply|destroy|import|state)\b", "changes infrastructure with terraform"),
    # The aws rules sit above the generic rm rule so `aws s3 rm` reports the more useful reason.
    (r"\baws\s+s3\s+(rm|rb|mv)\b", "deletes or moves S3 objects"),
    (r"\baws\s+s3\s+sync\b.*\s--delete\b", "deletes S3 objects with sync --delete"),
    (r"\baws\s+\S+\s+(delete|terminate|remove|deregister)-", "deletes or terminates AWS resources"),
    (r"\bgh\s+\S+\s+delete\b", "deletes a GitHub resource"),
    (r"\bgh\s+secret\b", "touches GitHub secrets"),
    # Plain `rm` already prompts via the settings ask rule; this catches it inside wrappers,
    # chains, heredocs, and `xargs rm`. `git rm` is recoverable and `modal volume rm` is
    # governed by the Modal environment rule, so both are excluded.
    (r"(?<![\w./-])(?<!git )(?<!volume )rm(?=\s|$)", "deletes files with rm"),
    (r"\bfind\b.*\s-delete\b", "deletes files with find -delete"),
    (r"\bshutil\.rmtree\(|\bos\.(remove|unlink|rmdir)\(|\.unlink\(", "deletes files from inline Python"),
    (r"\bmodal\s+secret\b", "touches Modal secrets"),
    (r"\bmodal\s+volume\s+delete\b", "deletes an entire Modal volume"),
    (r"(?i)\bdrop\s+(table|database)\b", "drops a database or table"),
    (r"\bfd\b.*\s(-x|-X|--exec|--exec-batch)(?=\s|=|$)", "runs a command on every file fd finds"),
    (r"\brg\b.*\s--pre(?=\s|=|$)", "runs a preprocessor command through rg --pre"),
    (r"\bgit\s+push\b.*\s(--force-with-lease|--force|-f|--delete|-d)(?=\s|=|$)", "force-pushes or deletes a remote branch"),
    # `+branch` force-pushes and `:branch` deletes, with no flag in sight.
    (r"\bgit\s+push\b.*\s[+:]\S", "force-pushes or deletes a remote branch via refspec"),
    (r"\bgit\s+reset\b.*\s--hard\b", "discards uncommitted work with reset --hard"),
    (r"\bgit\s+clean\b", "deletes untracked files with git clean"),
    (r"\bgit\s+branch\b.*\s-D\b", "force-deletes a branch"),
    (r"\bgit\s+checkout\b.*\s(--|\.)(?=\s|$)", "discards uncommitted changes with checkout"),
    (r"\bgit\s+stash\s+(drop|clear)\b", "deletes stashed work"),
]

MODAL_CLI = re.compile(
    r"\bmodal\s+(run|deploy|serve|shell|launch|volume|app|container|nfs|dict|queue)\b"
)
MODAL_ENV_VALUE = re.compile(r"(?:(?<!\S)(?:-e|--env)(?:\s+|=)|\bMODAL_ENVIRONMENT=)([^\s'\";&|]+)")
# Modal SDK calls in inline Python name their environment as a keyword argument.
MODAL_SDK_ENV_VALUE = re.compile(r"\benvironment_name\s*=\s*[\"']([^\"']+)[\"']")
GIT_RESTORE = re.compile(r"\bgit\s+restore\b")

SEGMENT_SPLIT = re.compile(r"&&|\|\||[;|\n]")


def modal_reason(segment):
    """Modal commands must name dev-ryan explicitly; the default env isn't visible from here."""
    sdk_others = sorted(set(MODAL_SDK_ENV_VALUE.findall(segment)) - {MODAL_DEV_ENV})
    if sdk_others:
        return f"targets Modal environment {', '.join(sdk_others)} from Python, not {MODAL_DEV_ENV}"
    if not MODAL_CLI.search(segment):
        return None
    envs = set(MODAL_ENV_VALUE.findall(segment))
    if not envs:
        return f"runs a Modal command without naming its environment (add -e {MODAL_DEV_ENV})"
    others = sorted(envs - {MODAL_DEV_ENV})
    if others:
        return f"targets Modal environment {', '.join(others)}, not {MODAL_DEV_ENV}"
    return None


def git_restore_reason(segment):
    """`git restore --staged` only unstages; anything touching the worktree discards edits."""
    if not GIT_RESTORE.search(segment):
        return None
    staged_only = re.search(r"\s(--staged|-S)\b", segment) and not re.search(r"\s(--worktree|-W)\b", segment)
    return None if staged_only else "discards uncommitted changes with git restore"


def reason_for(command):
    for segment in SEGMENT_SPLIT.split(command):
        for pattern, reason in SEGMENT_RULES:
            if re.search(pattern, segment):
                return reason
        reason = modal_reason(segment) or git_restore_reason(segment)
        if reason:
            return reason
    return None


def main():
    try:
        command = json.load(sys.stdin).get("tool_input", {}).get("command", "")
        reason = reason_for(command)
    except Exception:
        return
    if reason:
        json.dump(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "ask",
                    "permissionDecisionReason": f"Guard hook: this command {reason}. Confirm it is intended.",
                }
            },
            sys.stdout,
        )


if __name__ == "__main__":
    main()
