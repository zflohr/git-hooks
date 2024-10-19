#!/usr/bin/env bash
#
# Author: Zachary Flohr
#
# Update remote references of Git repositories that exist outside of
# the Git repository tht contains this script. The external repositories
# to be updated are specified in a script that gets sourced herein.
# Updates to the external repositories occur via pushes to upstream
# branches on tracked remote repositories.

print_git_progress() {
    case "${1}" in
        'fetch')
            local -r PROGRESS_MSG="\nFetching refs from: ${2}"
        ;;
        'rev-list')
            local -r PROGRESS_MSG="\n${2} ahead of ${3} by ${4} commits."
        ;;
        'push')
            local -r PROGRESS_MSG="\nPushing to ${2}"
        ;;
    esac
    print_message 0 "cyan" "${PROGRESS_MSG}"
}

push_to_remote_repo() {
    local -r REMOTE_URL=$(
        git -C "${1}" remote get-url $(
            git for-each-ref --format="%(upstream:remotename)" $(
                git symbolic-ref HEAD)))
    local -ar REFNAMES=($(git -C "${1}" rev-parse --symbolic-full-name @ @{u}))
    local -ar SYM_DIFF=($(git -C "${1}" rev-list --left-right --count @...@{u}))
    print_message 0 "gold" "In ${1}"
    print_git_progress "fetch" "${REMOTE_URL}"
    git -C "${1}" fetch
    print_git_progress "rev-list" "${REFNAMES[0]}"\
        "${REFNAMES[1]}" "${SYM_DIFF[0]}"
    [ "${1}" == "$(pwd)/" ] && print_git_progress "push" "${REMOTE_URL}" || {
        (( ${SYM_DIFF[0]} )) &&
            print_git_progress "push" "${REMOTE_URL}" &&
            git -C "${1}" push
    }
}

main() {
    . shell-scripts/git-hooks/external_git_repos.sh
    . shell-scripts/shared/notifications.sh
    for git_repo in "${!GIT_REPO_TO_SOURCE_DIR_MAP[@]}" "$(pwd)/"; do
        push_to_remote_repo "${git_repo}"
    done
}

main
