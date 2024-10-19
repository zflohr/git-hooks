# Specify the paths of external Git repositories to be updated during
# Git hooks as keys in the associative array GIT_REPO_TO_SOURCE_DIR_MAP.
# The value of each key is the path of the source directory of the main
# Git repository, relative to the repository's root, whence file diffs
# are replicated during the post-commit hook to the external repository
# whose path is the key.

declare -r GIT_DIR="${HOME}/github/"
declare -Ar GIT_REPO_TO_SOURCE_DIR_MAP=(
    ["${GIT_DIR}bootstraps/"]="shell-scripts/bootstraps/"
    ["${GIT_DIR}git-hooks/$(basename $(pwd))/"]="shell-scripts/git-hooks/"
    ["${GIT_DIR}git-hooks/$(basename $(pwd))/shared/"]="shell-scripts/shared/"
)
