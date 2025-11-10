#!/bin/bash
# Markdown Tag Filter - Ultra-simple CLI tool for filtering markdown by tags
# Usage: cat#tag filename.md
# Example: cat#foo example.md > filtered.md

# Main function that processes markdown files
function catmd() {
    local tag="$1"
    local file="$2"

    # Check if we got a tag and filename
    if [[ -z "$tag" || -z "$file" ]]; then
        echo "Usage: cat#<tag> <markdown-file>" >&2
        echo "Example: cat#foo example.md" >&2
        return 1
    fi

    # Check if file exists
    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' not found" >&2
        return 1
    fi

    # Process markdown file with awk
    awk -v tag="#$tag" '
    BEGIN {
        in_code_block = 0
        in_tagged_section = 0
        section_level = 0
        code_buffer = ""
        code_has_tag = 0
        list_buffer = ""
        list_has_tag = 0
        para_buffer = ""
        para_has_tag = 0
    }

    # Helper function to flush list buffer
    function flush_list() {
        if (list_buffer != "" && list_has_tag) {
            printf "%s", list_buffer
        }
        list_buffer = ""
        list_has_tag = 0
    }

    # Helper function to flush paragraph buffer
    function flush_para() {
        if (para_buffer != "" && para_has_tag) {
            printf "%s", para_buffer
        }
        para_buffer = ""
        para_has_tag = 0
    }

    # Detect code blocks
    /^```/ {
        flush_list()
        flush_para()

        if (in_code_block) {
            # Ending code block
            code_buffer = code_buffer $0 "\n"
            if (code_has_tag) {
                printf "%s", code_buffer
            }
            code_buffer = ""
            code_has_tag = 0
            in_code_block = 0
        } else {
            # Starting code block
            in_code_block = 1
            code_buffer = $0 "\n"
            code_has_tag = 0
        }
        next
    }

    # Inside code block
    in_code_block {
        code_buffer = code_buffer $0 "\n"
        if (index($0, tag) > 0) {
            code_has_tag = 1
        }
        next
    }

    # Detect headers
    /^#{1,6} / {
        flush_list()
        flush_para()

        # Get header level
        match($0, /^#{1,6}/)
        current_header_level = RLENGTH

        # Check if header has tag
        if (index($0, tag) > 0) {
            in_tagged_section = 1
            section_level = current_header_level
            print $0
        } else {
            # Check if this ends a tagged section
            if (in_tagged_section && current_header_level <= section_level) {
                in_tagged_section = 0
            }
        }
        next
    }

    # Handle content under tagged headers
    in_tagged_section {
        print $0
        next
    }

    # Detect list items (not in tagged section)
    /^[[:space:]]*[-*+] / || /^[[:space:]]*[0-9]+\. / {
        flush_para()

        # If we have a list buffer and this is a new item, flush it first
        if (list_buffer != "" && ($0 ~ /^[-*+0-9]/)) {
            flush_list()
        }

        # Start or continue list item buffer
        list_buffer = list_buffer $0 "\n"
        if (index($0, tag) > 0) {
            list_has_tag = 1
        }
        next
    }

    # Continuation of list item (indented content)
    /^[[:space:]]+/ && list_buffer != "" {
        list_buffer = list_buffer $0 "\n"
        if (index($0, tag) > 0) {
            list_has_tag = 1
        }
        next
    }

    # Empty line
    /^[[:space:]]*$/ {
        # Empty lines can be part of lists or paragraphs
        if (list_buffer != "") {
            list_buffer = list_buffer $0 "\n"
        } else if (para_buffer != "") {
            # Flush paragraph on empty line
            flush_para()
        }
        next
    }

    # Regular paragraph text
    {
        # Flush list if we encounter non-list content
        if (list_buffer != "") {
            flush_list()
        }

        # Add to paragraph buffer
        para_buffer = para_buffer $0 "\n"
        if (index($0, tag) > 0) {
            para_has_tag = 1
        }
    }

    END {
        # Flush any remaining buffers
        flush_list()
        flush_para()
    }
    ' "$file"
}

# Create dynamic command_not_found_handle for bash/zsh
# This intercepts commands like "cat#foo" and routes them to catmd
command_not_found_handle() {
    if [[ "$1" =~ ^cat#.+ ]]; then
        local tag="${1#cat#}"
        shift  # Remove the cat#tag from arguments
        # Call catmd with tag and remaining arguments
        catmd "$tag" "$@"
    else
        echo "bash: $1: command not found" >&2
        return 127
    fi
}

# For zsh compatibility
if [[ -n "$ZSH_VERSION" ]]; then
    command_not_found_handler() {
        command_not_found_handle "$@"
    }
fi
