#!/usr/bin/env bash
#
# Author: Zachary Flohr
#
# Update the commit history of Git repositories that exist outside of
# the Git repository that contains this script. The external
# repositories to be updated and the source directories of the main Git
# repository whence the external repositories receive their updates are
# specified in a script that gets sourced herein. Updates to the
# external repositories occur via file-diff replication at the commit
# level.

print_git_progress() {
    case "${1}" in
        'add')
            local -r PROGRESS_MSG="\nAdding the following files
                to the staging index:"
        ;;
        'commit')
            local -r PROGRESS_MSG="\nCreating a new commit..."
        ;;
        'rm')
            local -r PROGRESS_MSG="\nRemoving the following files
                from the staging index and the working tree:"
        ;;
    esac
    print_message 0 "cyan" "${PROGRESS_MSG}"
}

update_external_git_repo() {
    local -r COMMIT_MESSAGE=$(git log --pretty=format:"%B" -1 HEAD)
    print_message 0 "gold" "In ${1}"
    (( ${#added[*]} || ${#modified[*]} )) &&
        cp ${added[*]} ${modified[*]} ${1} &&
        print_git_progress "add" &&
        git -C "${1}" add -v \
            $(basename -a ${added[*]} ${modified[*]} | paste -s -d ' ')
    (( ${#deleted[*]} )) &&
        print_git_progress "rm" "${deleted[*]}" &&
        git -C "${1}" rm $(basename -a ${deleted[*]} | paste -s -d ' ')
    print_git_progress "commit"
    git -C "${1}" commit -m "${COMMIT_MESSAGE}"
}

get_diff_output() {
    [ -d ${1} ] && [ -d ${GIT_REPO_TO_SOURCE_DIR_MAP["${1}"]} ] || return 0
    local -a diff_statuses=($(git show --no-renames --name-status \
        --pretty=format:"%N" HEAD -- ${GIT_REPO_TO_SOURCE_DIR_MAP["${1}"]}))
    local -a added=() deleted=() modified=()
    for (( i=0; ${#diff_statuses[*]} - i; i+=2 )); do
        case "${diff_statuses[i]}" in
            'A')
                added+=(${diff_statuses[i + 1]})
            ;;
            'D')
                deleted+=(${diff_statuses[i + 1]})
            ;;
            'M')
                modified+=(${diff_statuses[i + 1]})
            ;;
        esac
    done
    ! (( ${#added[*]} || ${#deleted[*]} || ${#modified[*]} )) || {
        local -r LAST_STASH_ENTRY_BEFORE=$(git stash list -1 --format=%H)
        ! (( ${#modified[*]} )) || git stash push --quiet -- ${modified[*]}
        local -r LAST_STASH_ENTRY_AFTER=$(git stash list -1 --format=%H)
        update_external_git_repo ${1}
        [[ ${LAST_STASH_ENTRY_BEFORE} == ${LAST_STASH_ENTRY_AFTER} ]] ||
            git stash pop --quiet --index
    }
}

main() {
    . shell-scripts/git-hooks/external_git_repos.sh
    . shell-scripts/shared/notifications.sh
    for git_repo in "${!GIT_REPO_TO_SOURCE_DIR_MAP[@]}"; do
        get_diff_output "${git_repo}"
    done
    print_message 0 "gold" "In $(pwd)/"
    print_git_progress "commit"
}

main
