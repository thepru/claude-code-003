#!/bin/bash

# Demo script for markdown tag filter

echo "=== Markdown Tag Filter Demo ==="
echo ""

# Load the filter
source markdown-tag-filter.sh

echo "Example markdown file: example.md"
echo ""

echo "--- Filtering by #important (to stdout) ---"
tag#important example.md
echo ""

echo "--- Filtering by #dev (to stdout) ---"
tag#dev example.md
echo ""

echo "--- Filtering by #production (to stdout) ---"
tag#production example.md
echo ""

echo "--- Saving #setup filtered version with -w flag ---"
tag#setup -w example.md
echo ""
echo "Contents of example--tagged--setup.md:"
cat example--tagged--setup.md
