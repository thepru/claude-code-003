#!/bin/bash

# Demo script for markdown tag filter

echo "=== Markdown Tag Filter Demo ==="
echo ""

# Load the filter
source markdown-tag-filter.sh

echo "Example markdown file: example.md"
echo ""

echo "--- Filtering by #important ---"
cat#important example.md
echo ""

echo "--- Filtering by #dev ---"
cat#dev example.md
echo ""

echo "--- Filtering by #production ---"
cat#production example.md
echo ""

echo "--- Saving #setup filtered version ---"
cat#setup example.md > setup-guide.md
echo "Saved to setup-guide.md"
cat setup-guide.md
