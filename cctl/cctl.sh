#!/bin/bash

# Color codes
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
PURPLE='\033[1;35m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Icons
# ✔ ✘ ℹ ⚠ ⚡ ⚙ ❓ ❗

TEMPLATE_PATH="$HOME/git/repos/shellscripts/cctl/templates"

# Check if the script was called with the create argument
if [ "$1" = "create" ]; then
    # Check if the project name was specified
    if [ -z "$2" ]; then
        echo -e "${RED}✘${NC} No project name was specified"
        elif [ -d "$2" ]; then
        echo -e "${RED}✘${NC} A folder with the name ${PURPLE}$2${NC} already exists"
    else
        # Create the project folder and copy the template files
        mkdir "$2"
        cp "$TEMPLATE_PATH/main.c" "$2/"
        cp "$TEMPLATE_PATH/header.h" "$2/"
        cp "$TEMPLATE_PATH/makefile" "$2/"
        cp "$TEMPLATE_PATH/stdlib.h" "$2/"
        echo -e "${GREEN}✔${NC} Created the project ${PURPLE}$2${NC}"
    fi
    
    # Check if the script was called with the add argument
    elif [ "$1" = "add" ]; then
    
    # Check if the makefile exists
    if [ ! -f "makefile" ]; then
        echo -e "${RED}✘${NC} The ${PURPLE}makefile${NC} was not found in the current directory"
    else
        # Check if the filename was specified
        if [ -z "$2" ]; then
            echo -e "${RED}✘${NC} No filename was specified"
        else
            # Loop over the filenames
            for arg in "${@:2}"; do
                # Check if the filename already exists
                if [ -z "$arg" ]; then
                    echo -e "${RED}✘${NC} No filename was specified"
                    
                    # Check if the filename already exists
                    elif [ -f "$arg.c" ]; then
                    echo -e "${RED}✘${NC} A file with the name ${PURPLE}$arg.c${NC} already exists"
                    
                else
                    # Update makefile to compile filename.c
                    echo -e "\n$arg.o: $arg.c header.h stdlib.h\n\t\$(CC) \$(CFLAGS) -c $arg.c\n" >> makefile
                    
                    # Add filename.c to SRCS
                    sed -i "s/SRCS = .*/SRCS = main.c $arg.c/" makefile
                    
                    # Create filename.c and paste in the functions template
                    touch "$arg.c"
                    cp "$TEMPLATE_PATH/functions.c" "$arg.c"
                    
                    echo -e "${GREEN}✔${NC} Created ${PURPLE}$arg.c${NC} and and added ${PURPLE}$arg.c${NC} to makefile"
                    
                    # Update LDFLAGS to include functions.o
                    sed -i "s/LDFLAGS = .*/LDFLAGS = -lm $arg.o/" makefile
                    
                    echo -e "${GREEN}✔${NC} Updated LDFLAGS to include ${PURPLE}$arg.o${NC}"
                    
                    echo -e "${GREEN}✔${NC} Done"
                fi
            done
        fi
    fi
else
    # Display usage
    echo -e "${BLUE}ℹ${NC} Usage: cctl [command] [arguments]"
    echo -e "${BLUE}ℹ${NC} Commands:"
    echo -e "${BLUE}ℹ${NC}     create [project name] - Creates a new project"
    echo -e "${BLUE}ℹ${NC}     add [filenames] - Adds a new file to the project"
fi
