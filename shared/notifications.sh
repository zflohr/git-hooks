# Author: Zachary Flohr
#
# Functions for printing terminal-dependent messages and for shell
# exiting.

########################################################################
# Print a colorized message to stdout or stderr.
# Arguments:
#   1: An integer, which indicates to which data stream to send the
#      message: zero for stdout, non-zero for stderr.
#   2: The foreground color for the message. The color may be a name or
#      an integer. If an integer, it will be the argument to the
#      "setaf" terminal capability. 
#   3: A message to print.
# Outputs:
#   Writes $3 to stdout if $1 is zero.
#   Writes $3 to stderr if $1 is non-zero.
# Returns:
#   0
########################################################################
print_message() {
    local -r MESSAGE="\n${3}"
    local -i foreground_color=7
    case "${2}" in
        'red')
            foreground_color=1
        ;;
        'cyan')
            foreground_color=6
        ;;
        'gold')
            foreground_color=11
        ;;
        'yellow')
            foreground_color=3
        ;;
        [[:digit:]]*)
            foreground_color=${2}
        ;;
    esac
    tput sgr0 2> /dev/null                          # Turn off all attributes
    (( ${1} )) && tput rev 2> /dev/null             # Turn on reverse video mode
    tput bold 2> /dev/null                          # Turn on bold mode
    tput setaf ${foreground_color} 2> /dev/null     # Set foreground color
    (( ${1} )) && echo -e "${MESSAGE}" >&2 || echo -e "${MESSAGE}"
    tput sgr0 2> /dev/null                          # Turn off all attributes
    return 0
}

terminate() {
    local error_msg
    local -i exit_status=1
    case "${1}" in
        'check_binaries')
            error_msg="You must install the following tools "
            error_msg+="to run this script: ${1}"
        ;;
        'git')
            error_msg="\"git ${2}\" failed!\nTerminating..."
            exit_status=${3}
        ;;
    esac
    print_message 1 "red" "${error_msg}"
    exit ${exit_status}
}

print_git_progress() {
    local progress_msg
    case "${1}" in
        'add')
            progress_msg="Adding the following files to "
            progress_msg+="the staging index:\n${2}"
        ;;
        'commit')
            progress_msg="Creating a new commit..."
        ;;
        'rm')
            progress_msg="Removing the following files from the staging "
            progress_msg+="index and the working tree:\n${2}"
        ;;
        'fetch')
            progress_msg="Fetching refs from: ${2}"
        ;;
        'rev-list')
            progress_msg="${2} ahead of ${3} by ${4} commits."
        ;;
        'push')
            progress_msg="Pushing to ${2}"
        ;;
    esac
    print_message 0 "cyan" "${progress_msg}"
}

