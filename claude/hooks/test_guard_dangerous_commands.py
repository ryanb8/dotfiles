#!/usr/bin/python3
"""Table test for guard_dangerous_commands.py. Run: /usr/bin/python3 test_guard_dangerous_commands.py"""

import json
import subprocess
import sys
from pathlib import Path

HOOK = Path(__file__).with_name("guard_dangerous_commands.py")

SHOULD_ASK = [
    "terraform apply -auto-approve",
    "cd infra && uv run terraform destroy",
    "modal secret create foo BAR=1",
    "modal volume delete -e dev-ryan old_volume",
    'echo hi; psql -c "DROP TABLE users"',
    "fd -e png . out -x rm",
    "fd --exec-batch rm {} .",
    "rg --pre cat foo",
    "git push --force origin feat",
    "git push -f",
    "git push --force-with-lease origin feat",
    "git push -d origin feat",
    "git reset --hard HEAD~1",
    "git clean -fd",
    "git branch -D feat",
    "git checkout -- scripts/x.py",
    "git checkout .",
    "git restore scripts/x.py",
    "git restore --staged --worktree scripts/x.py",
    "git stash drop",
    "python3 - <<'EOF'\nimport os; os.system('git reset --hard')\nEOF",
    "modal run train.py",
    "modal run -e main train.py",
    "uv run modal deploy --env=main app.py",
    "MODAL_ENVIRONMENT=main modal run x.py",
    "modal volume put -e staging vol a b",
    "modal volume ls -e dev-ryan vol && modal run x.py",
    "env -u X bash -c 'modal run -e prod x.py'",
    # file deletion that dodges the `rm` prefix rule
    "cd out && rm -rf build",
    "bash -c 'rm -rf out'",
    "ls *.tmp | xargs rm",
    "find . -name '*.png' -delete",
    "find . -name '*.png' -exec rm {} +",
    "python3 - <<'EOF'\nimport shutil; shutil.rmtree('out')\nEOF",
    "python3 -c \"import os; os.remove('x.csv')\"",
    "python3 - <<'EOF'\nfrom pathlib import Path\nPath('x.csv').unlink()\nEOF",
    # aws / gh
    "aws s3 rm s3://bucket/key",
    "uv run aws s3 rb s3://bucket",
    "aws s3 sync . s3://bucket --delete",
    "aws ec2 terminate-instances --instance-ids i-123",
    "aws dynamodb delete-table --table-name t",
    "gh repo delete org/repo",
    "gh release delete v1.0",
    "gh secret set API_KEY",
    # Modal SDK from inline Python
    "python3 - <<'EOF'\nimport modal\nv = modal.Volume.from_name('vol', environment_name='main')\nEOF",
    # git refspec force-push / delete
    "git push origin +feat",
    "git push origin :feat",
]

SHOULD_PASS = [
    "ls -la",
    "terraform plan",
    "modal run -e dev-ryan train.py",
    "modal run --env=dev-ryan train.py",
    "MODAL_ENVIRONMENT=dev-ryan modal volume put vol a b",
    "modal volume rm -e dev-ryan vol /stale",
    "modal volume get -e dev-ryan vol /x .",
    "grep modal README.md",
    "grep -e main file.txt",
    "git commit -m 'fix'",
    "git push origin feat",
    "git push -u origin feat",
    "git restore --staged scripts/x.py",
    "git checkout -b feat",
    "git checkout main",
    "git reset HEAD scripts/x.py",
    "git push origin feat && grep -f patterns.txt log",
    "fd -e py",
    "rg -n 'force' src",
    "git rm scripts/old.py",
    "docker run --rm alpine true",
    "uv run ruff format .",
    "echo arm64",
    "aws s3 ls s3://bucket",
    "gh pr view 12",
    "gh release list",
    "git push origin HEAD:feat",
    "python3 - <<'EOF'\nimport modal\nv = modal.Volume.from_name('vol', environment_name='dev-ryan')\nEOF",
]


def asks(command):
    payload = json.dumps({"tool_name": "Bash", "tool_input": {"command": command}})
    out = subprocess.run([str(HOOK)], input=payload, capture_output=True, text=True, check=True).stdout
    return bool(out.strip())


failures = [("expected ask", c) for c in SHOULD_ASK if not asks(c)]
failures += [("expected pass", c) for c in SHOULD_PASS if asks(c)]
for kind, command in failures:
    print(f"FAIL ({kind}): {command!r}")
print(f"{len(SHOULD_ASK) + len(SHOULD_PASS) - len(failures)}/{len(SHOULD_ASK) + len(SHOULD_PASS)} passed")
sys.exit(1 if failures else 0)
