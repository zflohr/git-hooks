# Author: Zachary Flohr
#
# Specify the paths of external Git repositories to be updated during
# Git hooks as keys in the associative array GIT_REPO_TO_SOURCE_DIR_MAP.
# The value of each key is the path of the source directory of the main
# Git repository, relative to the repository's root, whence file diffs
# are replicated during the post-commit hook to the external repository
# whose path is the key.

declare -r GIT_DIR="${HOME}/github/"
declare -Ar EXTERNAL_REPO_MAP=(
    ["${GIT_DIR}bootstraps/"]="${GIT_DIR}verbosely/bootstraps/"
    ["${GIT_DIR}git-hooks/verbosely/"]="${GIT_DIR}verbosely/git-hooks/"
)
