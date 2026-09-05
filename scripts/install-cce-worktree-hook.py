"""Install the CCE block; shared installer also supports AI Central context."""
import subprocess
import sys
from worktree_hooks import main

if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, subprocess.CalledProcessError) as exc:
        print(f"CCE hook installation failed: {exc}", file=sys.stderr)
        sys.exit(1)
