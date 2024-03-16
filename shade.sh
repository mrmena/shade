#!/usr/bin/env bash
#
# Script Name: shade.sh
# Description: Alters the color of a command's output progressively, diminishing brightness with each line.
# Author: mrmena (tim@mrmena.com) / chatgpt (chat.openai.com)
# Date: 17/03/2024
# Version: 1.0.0
#
# Usage: ./shade.sh [OPTIONS] COLOR"
#   Options:"
#     -h, --help              Display this help message"
#     -c, --count NUM         Count the number of lines in the input (0-255, default: 12)"
#     -d, --delta VALUE       Apply delta to decrease brightness of each line (0-255, default: 16)"
#     -v, --verbose           Enable verbose output"
#     -q, --quiet             Suppresses non-essential output (overrides verbose option)"
#     -V, --version           Display version information"
#
#   Available colors: red, green, blue, yellow, cyan, magenta, white
#
# Dependencies:
#   getopt

# Example:"
#   ping mrmena.com | $(basename "$0") cyan"
#

VERSION="1.0.0"

# Available colours
COLOURS=("red" "green" "blue" "yellow" "cyan" "magenta" "white")

# The number of individual shades to cycle through
SHADE_COUNT=12

# The amount to alter the RBG shade value by for each colour.  Larger delta means bigger colour shift
SHADE_DELTA=16

# Set the default verbosity (off by default)
VERBOSE=false

# Whether or not to capture stderr
CAPTURE_STDERR=true

# Set quiet flag to false by default
QUIET=false

# Considerate echo function that reqpects the QUIET flag
_echo() {
    if [ "$QUIET" = false ]; then
        echo "$1"
    fi
}

# Usage
usage() {
    echo "Usage: $(basename "$0") [OPTIONS] COLOR"
    echo "Options:"
    echo "  -h, --help              Display this help message"
    echo "  -c, --count NUM         Count the number of lines in the input (0-255, default: 12)"
    echo "  -d, --delta VALUE       Apply delta to decrease brightness of each line (0-255, default: 16)"
    echo "  -v, --verbose           Enable verbose output"
    echo "  -q, --quiet             Suppresses non-essential output (overrides verbose option)"
    echo "  -V, --version           Display version information"
    echo
    echo "  Available colors: red, green, blue, yellow, cyan, magenta, white"
    echo
    echo "Example:"
    echo "  ping mrmena.com | $(basename "$0") cyan"
    echo
    echo "To capture standard output, pipe it to shade:"
    echo "  ping mrmena.com 2>&1 | $(basename "$0") cyan"
    echo
}

# Gets the shade of the current colour
get_colour() {
    brightness="$1"
    case "$COLOUR" in
        "red")
            echo "${brightness};0;0" ;;
        "green")
            echo "0;${brightness};0" ;;
        "blue")  #<-- Looks horrible in dark mode    
            echo "0;0;${brightness}" ;;
        "yellow")
            echo "${brightness};${brightness};0" ;;
        "cyan")
            echo "0;${brightness};${brightness}";;
        "magenta")
            echo "${brightness};0;${brightness}" ;;
        "white")
            echo "${brightness};${brightness};${brightness}" ;;
        *)
            echo "${brightness};${brightness};${brightness}" ;;
    esac
}

# Parse command line options
options=$(getopt -o hc:d:vqV --long help,quiet,verbose,version,count:,delta: -n "$(basename "$0")" -- "$@")
if [ $? -ne 0 ]; then
    usage
    exit 1
fi

# Set positional parameters based on getopt output
eval set -- "$options"

# Process command line options
while true; do
    case "$1" in
        -c | --count )
            SHADE_COUNT="$2"
            if ! [[ "$SHADE_COUNT" =~ ^[0-9]+$ ]] || [ "$SHADE_COUNT" -lt 0 ] || [ "$SHADE_COUNT" -gt 255 ]; then
                echo "Error: Invalid count value. Valid range is 0-255." >&2
                exit 1
            fi
            shift 2
            ;;
        -d | --delta )
            SHADE_DELTA="$2"
            if ! [[ "$SHADE_DELTA" =~ ^[0-9]+$ ]] || [ "$SHADE_DELTA" -lt 0 ] || [ "$SHADE_DELTA" -gt 255 ]; then
                echo "Error: Invalid delta value. Valid range is 0-255." >&2
                exit 1
            fi
            shift 2
            ;;
        -h | --help )
            usage
            exit 0
            ;;
        -q | --quiet )
            QUIET=true
            shift
            ;;
        -v | --verbose )
            VERBOSE=true
            shift
            ;;
        -V | --version )
            echo "shade v${VERSION}"
            exit 0
            ;;
        -- )
            shift
            break
            ;;
        * )
            echo "Internal error!" >&2
            exit 1
            ;;
    esac
done

# Get the requested colour in lowercase using bash trickery
if [ -n "$1" ]; then
    COLOUR="${1,,}"
    shift
fi

# Check if the colour is in the list
if [[ " ${COLOURS[*]} " =~ " $COLOUR " ]] then
    # It is. Remove the colour from the argument list
    shift
else
    # It's not.  Just set it to white
    COLOUR="white"
fi

# Set the initial colour
rgb_code=$(get_colour 255)
echo -en "\033[38;2;${rgb_code}m"

# Show the banner
_echo "shade v${VERSION}"

# Show settings
if [ "$VERBOSE" = true ]; then
    _echo "SHADE_COUNT: ${SHADE_COUNT}"
    _echo "SHADE_DELTA: ${SHADE_DELTA}"
    _echo "COLOUR: ${COLOUR}"
    _echo "VERBOSE: ${VERBOSE}"
    _echo "QUIET: ${QUIET}"
fi

# Initialize the counter. (There's probably an overflow condition here, but i can't see any sensible use case to correct it)
counter=0

# Let's go.  Pipe the output through our loop and give each line a slightly different shade
while IFS= read -r -s line
do
    brightness=$(( 255 - (counter % SHADE_COUNT) * SHADE_DELTA ))   # Calculate brightness
    rgb_code=$(get_colour $brightness)                              # Generate RBG colour value
    echo -en "\033[38;2;${rgb_code}m${line}\n"                      # Set the colour
    ((counter++))                                                   # Increment our counter
done

# Reset the colour to default
echo -en "\033[0m"