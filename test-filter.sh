#!/bin/bash

# Load the filter
source markdown-tag-filter.sh

# Test helper that calls catmd with the right context
test_filter() {
    local tag="$1"
    local file="$2"

    # Create a function with the cat#tag name
    eval "function cat#${tag}() { catmd \"\$@\"; }"

    # Call it
    "cat#${tag}" "$file"

    # Clean up
    unset -f "cat#${tag}"
}

echo "=== Testing cat#important ==="
test_filter important example.md
echo ""
echo "=== Testing cat#dev ==="
test_filter dev example.md
echo ""
echo "=== Testing cat#production ==="
test_filter production example.md
