#!/usr/bin/env bash
#
# Author: Zachary Flohr
#
# Update the commit history of Git repositories that exist outside of
# the Git repository that contains this git-hook script. The external
# repositories to be updated and the source directories of the main Git
# repository whence the external repositories receive their updates are
# specified in a script that gets sourced herein. Updates to the
# external repositories occur via file-diff replication at the commit
# level.

update_external_git_repo() {
    local -r COMMIT_MESSAGE=$(git log --pretty=format:"%B" -1 HEAD)
    local -ar ADDED_MODIFIED=(${added[*]} ${modified[*]})
    local basenames
    print_message 0 "gold" "In git repository ${1}"
    (( ${#added[*]} )) && {
        pushd ${1} > /dev/null
        mkdir --parents $(dirname ${added[*]})
        popd > /dev/null
    }
    (( ${#ADDED_MODIFIED[*]} )) && {
        for file in ${ADDED_MODIFIED[*]}; do
            cp ${file} ${1}$(dirname ${file})
        done
        print_git_progress "add" "${ADDED_MODIFIED[*]}"
        git -C "${1}" add ${ADDED_MODIFIED[*]}
    }
    (( ${#deleted[*]} )) &&
        basenames=$(basename --multiple ${deleted[*]}) &&
        print_git_progress "rm" "${basenames}" &&
        git -C "${1}" rm --quiet $(echo ${basenames})
    print_git_progress "commit"
    git -C "${1}" commit --message="${COMMIT_MESSAGE}"
}

get_diff_output() {
    [ -d ${1} ] && [ -d ${EXTERNAL_REPO_MAP["${1}"]} ] &&
        [ $(git -C "${EXTERNAL_REPO_MAP["${1}"]}" rev-parse --show-toplevel) ==\
            $(git rev-parse --show-toplevel) ] || return
    pushd ${EXTERNAL_REPO_MAP["${1}"]} > /dev/null
    local -a diff_statuses=($(git show --no-renames --name-status \
        --pretty=format:"%N" HEAD))
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
    popd > /dev/null
}

main() {
    . $(dirname ${0})/../shared/external_git_repos.sh
    . $(dirname ${0})/../shared/notifications.sh
    for git_repo in "${!EXTERNAL_REPO_MAP[@]}"; do
        get_diff_output "${git_repo}"
    done
    print_message 0 "gold" "In $(pwd)/"
    print_git_progress "commit"
}

main
