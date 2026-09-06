"""Install AI Central context seeding without requiring Code Context Engine."""
import subprocess
import sys
from worktree_hooks import main

if __name__ == "__main__":
    try:
        main(context=True)
    except (OSError, ValueError, subprocess.CalledProcessError) as exc:
        print(f"Context hook installation failed: {exc}", file=sys.stderr)
        sys.exit(1)
