# Functions for printing notifications to stdout.

print_filesystem_location() {
    local location="\nIn ${1}"
    tput -V &> /dev/null && {
        tput sgr0 2> /dev/null      # Turn off all attributes
        tput bold 2> /dev/null      # Turn on bold mode
        tput setaf 11 2> /dev/null   # Set foreground color to gold
        echo -e ${location}
        tput sgr0 2> /dev/null      # Turn off all attributes
    } || echo -e ${location}
}

