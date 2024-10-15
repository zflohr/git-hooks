#!/usr/bin/env bash

# This script is run by Git during the pre-push hook. It allows for
# updating remote references of Git repositories that exist outside of
# the Git repository tht contains this script. The external repositories
# to be updated are specified in a script that gets sourced herein.
# Updates to the external repositories occur via pushes to upstream
# branches on tracked remote repositories.

push_to_remote_repo() {}

main() {
    . shell-scripts/git-hooks/external_git_repos.sh
    for git_repo in "${!GIT_REPO_TO_SOURCE_DIR_MAP[@]}"; do
        push_to_remote_repo "${git_repo}"
    done
    print_filesystem_location "$(pwd)/"
}

#main
