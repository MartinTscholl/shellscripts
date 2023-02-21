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

# Display usage
display_usage() {
    echo -e "${BLUE}ℹ${NC} Usage: mkdir_struct [options] [folder name]"
    echo -e "${BLUE}ℹ${NC} Options:"
    echo -e "${BLUE}ℹ${NC}   -f, --force - Force the creation of the folder structure even if the folder name is too short"
    echo -e "${BLUE}ℹ${NC}   -s, --src - Create the src and pkgs folders inside the dev folder"
    echo -e "${BLUE}ℹ${NC}   -d, --docs - Create the docs folder inside the dev folder"
}

# Function to handle the --src flag
handle_src_flag() {
    local folder_name="$1"
    cd "$folder_name"/dev
    mkdir src pkgs
    cd ../..
    echo -e "${GREEN}✔${NC} Created the src and pkgs folders inside dev folder for '${PURPLE}$folder_name${NC}'"
}

handle_docs_flag() {
    local folder_name="$1"
    cd "$folder_name"/dev
    mkdir docs
    cd ../..
    echo -e "${GREEN}✔${NC} Created the docs folder inside dev folder for '${PURPLE}$folder_name${NC}'"
}

# Function to create the required folders structure
create_folder_structure() {
    local folder_name="$1"
    local force_flag=0
    local src_flag=0
    local docs_flag=0
    
    if [ "${1#-}" != "$1" ]; then
        echo -e "${RED}✘${NC} Invalid option '${RED}$1${NC}'"
        return 1
    fi
    
    if [[ ! $folder_name =~ ^[[:alnum:]] ]]; then
        echo -e "${RED}✘${NC} Folder name '${RED}$folder_name${NC}' is not alphanumeric."
        return 1
    fi
    
    if [ -n "$2" ] && [ "$2" -eq 1 ]; then
        force_flag=1
    fi
    
    if [ -n "$3" ] && [ "$3" -eq 1 ]; then
        src_flag=1
    fi
    
    if [ -n "$4" ] && [ "$4" -eq 1 ]; then
        docs_flag=1
    fi
    
    if [ ${#folder_name} -lt 6 ] && [ $force_flag -ne 1 ]; then
        echo -e "${RED}✘${NC} Folder name '${RED}$folder_name${NC}' is too short. Minimum length is ${RED}6${NC} characters."
        return 1
    fi
    
    if [ -d "$folder_name" ]; then
        echo -e "${RED}✘${NC} Folder ${RED}$folder_name${NC} already exists."
        return 1
    fi
    
    mkdir "$folder_name"
    cd "$folder_name"
    mkdir dev share aux
    cd ..
    
    if [ $src_flag -eq 1 ]; then
        handle_src_flag "$folder_name"
    fi
    
    if [ $docs_flag -eq 1 ]; then
        handle_docs_flag "$folder_name"
    fi
    
    echo -e "${GREEN}✔${NC} Created the folder structure for ${PURPLE}$folder_name${NC}"
}

# Check if no arguments were passed
if [ $# -eq 0 ]; then
    display_usage
    exit 1
fi

# Loop through the passed arguments and create the folder structure for each
for arg in "$@"; do
    case "$arg" in
        --force|-f)
            force=1
        ;;
        --src|-s)
            src=1
        ;;
        --docs|-d)
            docs=1
        ;;
        *) # not a flag, call function with flags
            create_folder_structure "$arg" "$force" "$src" "$docs"
            # reset flags to default
            force=0
            src=0
            docs=0
        ;;
    esac
done

echo -e "${GREEN}✔${NC} Done"