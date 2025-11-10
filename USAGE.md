# Markdown Tag Filter - Usage Guide

## Quick Start

### Installation

Add to your shell profile (~/.bashrc or ~/.zshrc):

```bash
source /path/to/markdown-tag-filter.sh
```

Then reload your shell:

```bash
source ~/.bashrc  # or source ~/.zshrc
```

## Basic Usage

### Filter by tag

```bash
cat#important example.md
```

Shows all markdown elements tagged with `#important`.

### Save filtered output

```bash
cat#dev example.md > dev-docs.md
```

### Multiple operations

```bash
# Filter by one tag, then another
cat#important docs.md > important.md
cat#dev docs.md > dev.md

# Combine with other tools
cat#important docs.md | wc -l
cat#important docs.md | grep "API"
```

## How It Works

The filter extracts markdown elements containing your specified tag:

1. **Tagged headers** → Includes header AND all content until next same-level header
2. **Tagged list items** → Includes entire list item (even multi-line)
3. **Tagged paragraphs** → Includes entire paragraph block
4. **Tagged code blocks** → Includes entire code block if it contains the tag

## Examples

Given this markdown:

```markdown
# API Documentation #important

This covers all API endpoints.

## Authentication #important #security

Use OAuth 2.0 for authentication.

## Rate Limiting #advanced

Standard rate limits apply.

## Endpoints

- GET /api/users #important
- POST /api/users #important
- DELETE /api/users #admin
```

Running `cat#important example.md` produces:

```markdown
# API Documentation #important

This covers all API endpoints.

## Authentication #important #security

Use OAuth 2.0 for authentication.

- GET /api/users #important
- POST /api/users #important
```

Note how:
- "# API Documentation #important" includes its content until "## Authentication"
- "## Authentication #important" is also tagged and includes its content
- "## Rate Limiting" section is excluded (no #important tag)
- Individual list items with #important are included
- "DELETE /api/users #admin" is excluded (no #important tag)

## Tips

- Tags must be in format `#tagname` (no spaces)
- Tags can appear anywhere in an element
- Multiple tags per element are supported (e.g., `#important #dev`)
- Use meaningful tag names: `#todo`, `#important`, `#v2`, `#review`, etc.

## Use Cases

1. **Project planning** - Tag tasks by priority or phase
2. **Documentation** - Extract sections for different audiences
3. **Code review** - Mark items needing review
4. **Version planning** - Tag features by version (#v1, #v2)
5. **Role-based docs** - Filter content by role (#admin, #dev, #user)
