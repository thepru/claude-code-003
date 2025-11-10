#!/bin/bash
# Markdown Tag Filter - Ultra-simple CLI tool for filtering markdown by tags
# Usage: tag#foo filename.md
# Usage: tag#foo -w filename.md (writes to filename--tagged--foo.md)
# Example: tag#foo example.md
# Example: tag#foo -w example.md

# Main function that processes markdown files
function tagmd() {
    local tag="$1"
    local write_mode=0
    local file=""

    shift  # Remove tag from arguments

    # Parse arguments for -w flag
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -w)
                write_mode=1
                shift
                ;;
            *)
                file="$1"
                shift
                ;;
        esac
    done

    # Check if we got a tag and filename
    if [[ -z "$tag" || -z "$file" ]]; then
        echo "Usage: tag#<tag> [-w] <markdown-file>" >&2
        echo "Example: tag#foo example.md" >&2
        echo "Example: tag#foo -w example.md  (writes to example--tagged--foo.md)" >&2
        return 1
    fi

    # Check if file exists
    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' not found" >&2
        return 1
    fi

    # Determine output destination
    local output_file=""
    if [[ $write_mode -eq 1 ]]; then
        # Generate output filename: basename--tagged--tagname.md
        local basename="${file%.md}"
        output_file="${basename}--tagged--${tag}.md"
    fi

    # Process markdown file with awk
    awk -v tag="#$tag" '
    BEGIN {
        in_code_block = 0
        in_tagged_section = 0
        section_level = 0
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

    # Code blocks are skipped entirely
    /^```/ {
        flush_list()
        flush_para()

        if (in_code_block) {
            in_code_block = 0
        } else {
            in_code_block = 1
        }
        next
    }

    # Skip lines inside code blocks
    in_code_block {
        next
    }

    # Detect headers
    /^#+ / {
        flush_list()
        flush_para()

        # Get header level
        match($0, /^#+/)
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
    ' "$file" > "${output_file:-/dev/stdout}"

    # If writing to file, show success message
    if [[ $write_mode -eq 1 ]]; then
        echo "Filtered content written to: $output_file"
    fi
}

# Create dynamic command_not_found_handle for bash/zsh
# This intercepts commands like "tag#foo" and routes them to tagmd
command_not_found_handle() {
    if [[ "$1" =~ ^tag#.+ ]]; then
        local tag="${1#tag#}"
        shift  # Remove the tag#tag from arguments
        # Call tagmd with tag and remaining arguments
        tagmd "$tag" "$@"
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
