#!/bin/bash

# Script to replace watchcon with watchcon in all files recursively
# Preserves Git URLs and handles case-sensitive variants

set -e

# Function to check if a line contains a Git URL
is_git_url() {
    local line="$1"
    # Check for various Git URL patterns
    if [[ "$line" =~ (https?://[^/]*github\.com/watchcon|git@[^:]*github\.com:watchcon|ssh://git@[^/]*/watchcon) ]]; then
        return 0  # true - is a Git URL
    fi
    return 1  # false - not a Git URL
}

# Function to perform case-sensitive replacements
replace_watchcon() {
    local file="$1"
    local temp_file=$(mktemp)
    local modified=false
    
    while IFS= read -r line; do
        # Skip lines that contain Git URLs
        if is_git_url "$line"; then
            echo "$line" >> "$temp_file"
        else
            # Perform replacements with different cases
            local new_line="$line"
            new_line="${new_line//watchcon/watchcon}"
            new_line="${new_line//WatchCon/WatchCon}"
            new_line="${new_line//WATCHCON/WATCHCON}"
            new_line="${new_line//Watchcon/Watchcon}"
            new_line="${new_line//watchCon/watchCon}"
            new_line="${new_line//WatchCON/WatchCON}"
            
            # Check if line was modified
            if [[ "$new_line" != "$line" ]]; then
                modified=true
            fi
            
            echo "$new_line" >> "$temp_file"
        fi
    done < "$file"
    
    # Only update file if modifications were made
    if [[ "$modified" == true ]]; then
        mv "$temp_file" "$file"
        echo "Modified: $file"
    else
        rm "$temp_file"
    fi
}

# Main execution
echo "Starting recursive replacement of watchcon with watchcon..."
echo "Preserving Git URLs..."

# Find all files recursively, excluding .git directory and binary files
find . -type f -not -path "./.git/*" -not -path "./target/*" -not -path "./flutter/build/*" -not -path "./flutter/.dart_tool/*" | while read -r file; do
    # Skip binary files by checking if file contains null bytes
    if ! grep -qI . "$file" 2>/dev/null; then
        continue
    fi
    
    # Process the file
    replace_watchcon "$file"
done

