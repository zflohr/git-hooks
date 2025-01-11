#!/usr/bin/env bash
#
# Author: Zachary Flohr
#
# Update remote references of Git repositories that exist outside of
# the Git repository tht contains this script. The external repositories
# to be updated are specified in a script that gets sourced herein.
# Updates to the external repositories occur via pushes to upstream
# branches on tracked remote repositories.

push_to_remote_repo() {
    local -r REMOTE_URL=$(
        git -C "${1}" remote get-url $(
            git for-each-ref --format="%(upstream:remotename)" $(
                git symbolic-ref HEAD)))
    local -ar REFNAMES=($(git -C "${1}" rev-parse --symbolic-full-name @ @{u}))
    local -ar SYM_DIFF=($(git -C "${1}" rev-list --left-right --count @...@{u}))
    print_message 0 "gold" "In ${1}"
    print_git_progress "fetch" "${REMOTE_URL}"
    git -C "${1}" fetch || terminate "git" "fetch" $?
    print_git_progress "rev-list" "${REFNAMES[0]}"\
        "${REFNAMES[1]}" "${SYM_DIFF[0]}"
    [ "${1}" == "$(pwd)/" ] && print_git_progress "push" "${REMOTE_URL}" || {
        ! (( ${SYM_DIFF[0]} )) || {
            print_git_progress "push" "${REMOTE_URL}" &&
                git -C "${1}" push || terminate "git" "push" $?
        }
    }
}

main() {
    . shared/external_git_repos.sh; . shared/notifications.sh
    for git_repo in "${!GIT_REPO_TO_SOURCE_DIR_MAP[@]}" "$(pwd)/"; do
        push_to_remote_repo "${git_repo}"
    done
}

main
