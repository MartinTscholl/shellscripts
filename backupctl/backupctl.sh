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

# Configuration paths and naming
CONFIG_PATH=$HOME/git/repos/shellscripts/backupctl/
CONFIG_FILE=config.ini
CONFIG_SOURCE_DIRECTORIES="full_source_directories"
CONFIG_SCHOOL_SOURCE_DIRECTORIES="school_source_directories"
CONFIG_DESTINATION_DIRECTORY="destination_directory"
CONFIG_EXCLUDE_PATTERNS="exclude_patterns"

# Source directories
src_dirs=($(sed -n "/$CONFIG_SOURCE_DIRECTORIES.*=.*\[/,/]/p" $CONFIG_PATH/$CONFIG_FILE | sed '1d;$d;s/^ *//;s/ *$//' | tr -d " " | sed '/^#/d' | tr -d '"' | sed 's/,*$//'))
SCHOOL_SRC_DIRS=($(sed -n "/$CONFIG_SCHOOL_SOURCE_DIRECTORIES.*=.*\[/,/]/p" $CONFIG_PATH/$CONFIG_FILE | sed '1d;$d;s/^ *//;s/ *$//' | tr -d " " | sed '/^#/d' | tr -d '"' | sed 's/,*$//'))

# Destination directory
dst_dir=$(grep -oP "^(?!#).*${CONFIG_DESTINATION_DIRECTORY} = \"\K[^\"]+" $CONFIG_PATH/$CONFIG_FILE)

# Exclude patterns
EXCLUDE_PATTERNS=($(sed -n "/$CONFIG_EXCLUDE_PATTERNS.*=.*\[/,/]/p" $CONFIG_PATH/$CONFIG_FILE | sed '1d;$d;s/^ *//;s/ *$//' | tr -d " " | sed '/^#/d'| tr -d '"' | sed 's/,*$//'))

# Other globally used variables
BACKUP_NAME="Backup"

# Display the usage of the script
display_usage() {
    echo -e "${BLUE}ℹ${NC} Usage: backupcli [command] [...] [options]"
    echo -e "${BLUE}ℹ${NC} Commands:"
    echo -e "${BLUE}ℹ${NC}   create: Create a backup archive"
    echo -e "${BLUE}ℹ${NC}      full: Create a backup of every source directory"
    echo -e "${BLUE}ℹ${NC}      scbkp: Create a backup of the school directory"
    echo -e "${BLUE}ℹ${NC}          -d, --destination: Specify the destination directory"
    echo -e "${BLUE}ℹ${NC}   add: Add a path to the source directories"
    echo -e "${BLUE}ℹ${NC}   remove: Remove a path from the source directories"
    echo -e "${BLUE}ℹ${NC}   include: Includes a pattern, so the backup includes anything with that pattern"
    echo -e "${BLUE}ℹ${NC}   exclude: Excludes a pattern, so the backup excludes anything with that pattern"
    echo -e "${BLUE}ℹ${NC}   list:"
    echo -e "${BLUE}ℹ${NC}      sources: List the source directories"
    echo -e "${BLUE}ℹ${NC}      destination: List the destination directory"
    echo -e "${BLUE}ℹ${NC}      patterns: List the exclude patterns"
}

# Create a backup archive and moves it to the destination directory
create_backup() {
    local args=("$@")
    
    # Check if the script was called with the full argument
    if [[ "${args[1]}" = "full" ]]; then
        BACKUP_NAME="Full-Backup"
 
        choose_destination "${args[@]}"
        
        # Check if the script was called with the scbkp argument
        elif [[ "${args[1]}" = "scbkp" ]]; then
        unset src_dirs[*]
        src_dirs=$SCHOOL_SRC_DIRS
        
        BACKUP_NAME="School-Backup"
        
        choose_destination "${args[@]}"
    else
        display_usage
        exit 1
    fi
    
    # Check if the source directories and destination directory exist
    for dir in "${src_dirs[@]}" "$dst_dir"; do
        if [[ ! -d "$dir" ]]; then
            echo -e "${RED}✘${NC} The directory ${PURPLE}$dir${NC} does not exist"
            exit 1
        fi
    done
    
    local exclude_patterns=()
    local exclude_args=""
    # Loop over the source directories and create a new pattern for the exclude patterns and print the size of each directory
    for dir in "${src_dirs[@]}"; do
        # Loop over the exclude patterns and create a new pattern for the zip command and append the exclude patterns to the du command
        for pattern in "${EXCLUDE_PATTERNS[@]}"; do
            local exclude_patterns+=("*${pattern}*")
            local exclude_args="$exclude_args --exclude=$pattern"
        done
        
        # Calculate the size of the directory with the exclude patterns applied
        local size=$(du -hs $exclude_args "$dir" | cut -f1)
        echo -e "${BLUE}ℹ${NC} Size of ${PURPLE}$dir${NC}: ${PURPLE}$size${NC}"
    done
    
    # Ask the user if they want to continue
    local answer="n"
    echo -n -e "${YELLOW}❓${NC} Proceed with backing up? [Y/n] "
    read -p "" answer
    if [[ "$answer" != "Y" && "$answer" != "y" && "$answer" != "" ]]; then
        echo -e "${YELLOW}⚡${NC} Aborting"
        exit 0
    fi
    
    # Check again after user desicion if the source directories and destination directory exist
    for dir in "${src_dirs[@]}" "$dst_dir"; do
        if [[ ! -d "$dir" ]]; then
            echo -e "${RED}✘${NC} The directory ${PURPLE}$dir${NC} does not exist"
            exit 1
        fi
    done
    
    # Create a zip archive of the source directories excluding the exclude patterns
    local zip_name="${BACKUP_NAME}-0.zip"
    local i=1
    while [[ -f "$dst_dir/$zip_name" ]]; do
        local zip_name="${BACKUP_NAME}-$i.zip"
        local i=$((i+1))
    done
    
    # Create the archive
    echo -e "${BLUE}⚙${NC} Creating archive ${PURPLE}$zip_name${NC}..."
    zip -rq "$zip_name" "${src_dirs[@]}" -x "${exclude_patterns[@]}"
    
    if [[ ! -f "$zip_name" ]]; then
        echo -e "${RED}✘${NC} Failed to create archive ${PURPLE}$zip_name${NC}"
        exit 1
    fi
    
    # Print the size of the archive
    local size=$(du -h "$zip_name" | cut -f1)
    echo -e "${BLUE}ℹ${NC} Size of ${PURPLE}$zip_name${NC}: ${PURPLE}$size${NC}"
    
    # Ask the user if they want to continue
    local answer="n"
    echo -n -e "${YELLOW}❓${NC} Proceed to move the archive to ${PURPLE}$dst_dir${NC}? [Y/n] "
    read -p "" answer
    if [[ "$answer" != "Y" && "$answer" != "y" && "$answer" != "" ]]; then
        echo -e "${YELLOW}⚡${NC} Aborting"
        exit 0
    fi
    
    # Check again after user desicion if the destination directory exists
    if [[ ! -d "$dst_dir" ]]; then
        echo -e "${RED}✘${NC} The directory ${PURPLE}$dst_dir${NC} does not exist"
        exit 1
    fi
    
    # Move the archive to the destination directory
    echo -e "${BLUE}⚙${NC} Moving archive to ${PURPLE}$dst_dir${NC}..."
    mv "$zip_name" "$dst_dir"
    echo -e "${GREEN}✔${NC} Archive moved to ${PURPLE}$dst_dir${NC}"
    
    echo -e "${GREEN}✔${NC} Done"
}

# Chooses the destination directory
choose_destination() {
    local args=("$@")
    
    if [[ ${#args[@]} -ge 3 ]]; then
        if [[ "${args[2]}" = "--destination" || "${args[2]}" = "-d" ]]; then
            if [[ ! -z "${args[3]}" ]]; then
                dst_dir="${args[3]}"
            else
                echo -e "${RED}✘${NC} No destination directory specified"
                exit 1
            fi
        else
            echo -e "${RED}✘${NC} Invalid option: ${PURPLE}$3${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}⚠${NC} No destination directory specified. Using default destination directory."
    fi
}

add_remove_source() {
    local args=("$@")
    
    # Check if CONFIG_FILE exists
    if [ ! -f "$CONFIG_PATH/$CONFIG_FILE" ]; then
        echo -e "${RED}✘${NC} The ${PURPLE}$CONFIG_FILE${NC} file was not found in ${PURPLE}$CONFIG_PATH${NC}"
        exit 1
    fi
    
    # Parse command-line arguments
    local action=${args[0]}
    local source=${args[1]}
    
    # Check if source is valid
    if [ -z "$source" ]; then
        echo -e  "${RED}✘${NC} Invalid source"
        exit 1
    fi
    
    if [ "$source" = "." ]; then
        echo -e "${RED}✘${NC} Source ${PURPLE}$source${NC} is not an absolute path"
        exit 1
    fi
    
    # Check if source is already in CONFIG_FILE
    if awk "/\[$CONFIG_SOURCE_DIRECTORIES\]/{flag=1;next}/\]/{flag=0}flag" $CONFIG_PATH/$CONFIG_FILE | tr -d " " | sed '/^#/d'| grep -wq "$source"; then
        if [ "$action" == "remove" ]; then
            # Remove source
            sed -i "/$CONFIG_SOURCE_DIRECTORIES = \[/,/]/ { \#\"$source\"# d }" "$CONFIG_PATH/$CONFIG_FILE"

            echo -e "${GREEN}✔${NC} Source ${PURPLE}$source${NC} removed from ${PURPLE}$CONFIG_FILE${NC}"
        else
            echo -e "${YELLOW}⚠${NC} Source ${PURPLE}$source${NC} already exists in ${PURPLE}$CONFIG_FILE${NC}"
        fi
    else
        if [ "$action" == "add" ]; then
            if [[ "$source" != /* ]]; then
                echo -e "${RED}✘${NC} Source ${PURPLE}$source${NC} is not an absolute path"
                exit 1
            fi
            
            if [[ ! -d "$source" ]]; then
                echo -e "${RED}✘${NC} Source ${PURPLE}$source${NC} does not exist"
                exit 1
            fi
            
            # Add source
            sed -i "/$CONFIG_SOURCE_DIRECTORIES = \[/,/]/ s#]#    \"$source\",\n]#" "$CONFIG_PATH/$CONFIG_FILE"
            
            echo -e "${GREEN}✔${NC} Source ${PURPLE}$source${NC} added to ${PURPLE}$CONFIG_FILE${NC}"
        else
            echo -e "${YELLOW}⚠${NC} Source ${PURPLE}$source${NC} not found in ${PURPLE}$CONFIG_FILE${NC}"
        fi
    fi
}

# Includes or excludes a pattern from the excluded patterns
include_exclude_pattern() {
    local args=("$@")
    
    # Check if CONFIG_FILE exists
    if [ ! -f "$CONFIG_PATH/$CONFIG_FILE" ]; then
        echo -e "${RED}✘${NC} The ${PURPLE}$CONFIG_FILE${NC} file was not found in ${PURPLE}$CONFIG_PATH${NC}"
        exit 1
    fi
    
    # Parse command-line arguments
    local action=${args[0]}
    local pattern=${args[1]}
    
    # Check if pattern is valid
    if [ -z "$pattern" ]; then
        echo -e  "${RED}✘${NC} Invalid pattern"
        exit 1
    fi
    
    # Check if pattern is already in CONFIG_FILE
    if awk "/\[$CONFIG_EXCLUDE_PATTERNS\]/{flag=1;next}/\]/{flag=0}flag" $CONFIG_PATH/$CONFIG_FILE | tr -d " " | sed '/^#/d' | grep -wq "$pattern"; then
        if [ "$action" == "include" ]; then
            # Remove pattern
            sed -i "/$CONFIG_EXCLUDE_PATTERNS = \[/,/]/ { /\"$pattern\"/ d }" "$CONFIG_PATH/$CONFIG_FILE"
            echo -e "${GREEN}✔${NC} Pattern ${PURPLE}$pattern${NC} is now included in ${PURPLE}backups${NC}"
        else
            echo -e "${YELLOW}⚠${NC} Pattern ${PURPLE}$pattern${NC} is already excluded in the ${PURPLE}backups${NC}"
        fi
    else
        if [ "$action" == "exclude" ]; then
            # Add pattern
            sed -i "/$CONFIG_EXCLUDE_PATTERNS = \[/,/]/ s/]/    \"$pattern\",\n]/" "$CONFIG_PATH/$CONFIG_FILE"
            echo -e "${GREEN}✔${NC} Pattern ${PURPLE}$pattern${NC} is now excluded from ${PURPLE}backups${NC}"
        else
            echo -e "${YELLOW}⚠${NC} Pattern ${PURPLE}$pattern${NC} is already included in the ${PURPLE}backups${NC}"
        fi
    fi
}

list() {
    local args=("$@")
    
    if [ "${args[1]}" == "sources" ]; then
        list_source_directories
        
        elif [ "${args[1]}" == "destination" ]; then
        list_destination_directory
        
        elif [ "${args[1]}" == "patterns" ]; then
        list_excluded_patterns
        
    else
        echo -e "${RED}✘${NC} Invalid argument: ${PURPLE}${args[1]}${NC}"
        exit 1
    fi
}

list_source_directories() {
    # Check if CONFIG_FILE exists
    if [ ! -f "$CONFIG_PATH/$CONFIG_FILE" ]; then
        echo -e "${RED}✘${NC} The ${PURPLE}$CONFIG_FILE${NC} file was not found in ${PURPLE}$CONFIG_PATH${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}⚙${NC} Getting source directories..."
    local src_dirs=$(awk "/\[$CONFIG_SOURCE_DIRECTORIES\]/{flag=1;next}/\]/{flag=0}flag" $CONFIG_PATH/$CONFIG_FILE | tr -d " " | sed '/^#/d' | tail -n +2 | tr -d "\"" | tr -d ",")
    
    if [ -z "$src_dirs" ]; then
        echo -e "${RED}✘${NC} No source directories found"
        exit 1
    fi
    
    echo -e "${GREEN}✔${NC} Source directories:"
    
    for line in ${src_dirs}; do
        echo -e "\t${PURPLE}${line}${NC}"
    done
    
    echo -e "${GREEN}✔${NC} Done"
}

list_destination_directory() {
    # Check if CONFIG_FILE exists
    if [ ! -f "$CONFIG_PATH/$CONFIG_FILE" ]; then
        echo -e "${RED}✘${NC} The ${PURPLE}$CONFIG_FILE${NC} file was not found in ${PURPLE}$CONFIG_PATH${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}⚙${NC} Getting the destination directory..."
    local dst_dir=$(grep -oP "^(?!#).*${CONFIG_DESTINATION_DIRECTORY} = \"\K[^\"]+" $CONFIG_PATH/$CONFIG_FILE)
    
    if [ -z "$dst_dir" ]; then
        echo -e "${RED}✘${NC} No destination directory found"
        exit 1
    fi
    
    echo -e "${GREEN}✔${NC} Destination directory:"
    
    for line in ${dst_dir}; do
        echo -e "\t${PURPLE}${line}${NC}"
    done
    
    echo -e "${GREEN}✔${NC} Done"
}

list_excluded_patterns() {
    # Check if CONFIG_FILE exists
    if [ ! -f "$CONFIG_PATH/$CONFIG_FILE" ]; then
        echo -e "${RED}✘${NC} The ${PURPLE}$CONFIG_FILE${NC} file was not found in ${PURPLE}$CONFIG_PATH${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}⚙${NC} Getting excluded patterns..."
    local exclude_patterns=$(awk "/\[$CONFIG_EXCLUDE_PATTERNS\]/{flag=1;next}/\]/{flag=0}flag" $CONFIG_PATH/$CONFIG_FILE | tr -d " " | sed '/^#/d' | tail -n +2 | tr -d "\"" | tr -d ",")
    
    if [ -z "$exclude_patterns" ]; then
        echo -e "${YELLOW}⚠${NC} No excluded patterns found"
        exit 1
    fi
    
    echo -e "${GREEN}✔${NC} Excluded patterns:"
    
    for line in ${exclude_patterns}; do
        echo -e "\t${PURPLE}${line}${NC}"
    done
    
    echo -e "${GREEN}✔${NC} Done"
}

# Check if CONFIG_PATH is set
if [ -z "$CONFIG_PATH" ]; then
    echo -e "${RED}✘${NC} The path to the ${PURPLE}$CONFIG_FILE${NC} is not set"
    exit 1
fi

# Check if the script was called with the create argument
if [ "$1" = "create" ]; then
    create_backup "$@"
    
    # Check if the script was called with the include or export argument
    elif [[ "$1" = @(include|exclude) ]]; then
    include_exclude_pattern "$@"
    
    # Check if the script was called with the add argument
    elif [[ "$1" = @(add|remove) ]]; then
    add_remove_source "$@"
    
    # Check if the script was called with the list argument
    elif [ "$1" = "list" ]; then
    list "$@"
    
else
    display_usage
    exit 1
fi
