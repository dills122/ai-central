"""Keep checkout-internal relative links; anchor external links to their source."""
import os
from pathlib import Path
import sys

source_root, source_link, target = sys.argv[1:]
if os.path.isabs(target):
    print(target)
else:
    # Lexical normalization deliberately keeps internal symlink chains aimed
    # at the new worktree rather than following them back into the source.
    anchored = os.path.join(os.path.dirname(source_link), target)
    absolute = Path(os.path.abspath(anchored))
    # Keep the original traversal in the emitted absolute path: alias/.. must
    # follow the alias on the filesystem, not disappear during normalization.
    print(target if absolute.is_relative_to(Path(source_root)) else anchored)
