# Markdown Tag Filter

Ultra-simple CLI tool for filtering markdown files by tags. Filter markdown elements (headings, list items, paragraphs) that contain specific tags.

## Features

- **Simple syntax**: `tag#tagname filename.md`
- **Write to file**: `tag#tagname -w filename.md` creates `filename--tagged--tagname.md`
- **Smart filtering**:
  - Headers with tags include all content until the next same-level header (excluding differently-tagged content)
  - Code blocks under tagged headers are included
  - List items with tags are included in their entirety
  - Paragraphs with tags are included in their entirety
- **Pure shell**: No dependencies, just bash/zsh and awk

## Installation

### For Bash #test
Add to your `~/.bashrc`:

```bash
source /path/to/markdown-tag-filter.sh
```

Then reload:

```bash
source ~/.bashrc
```

### For Zsh

Add to your `~/.zshrc`:

```bash
source /path/to/markdown-tag-filter.sh
```

Then reload:

```bash
source ~/.zshrc
```

### Quick Install (Copy to Profile)

Simply copy the contents of `markdown-tag-filter.sh` and paste into your `~/.bashrc` or `~/.zshrc` file, then reload your shell.

## Usage

### Basic filtering (print to stdout)

```bash
tag#important example.md
```

This will display all elements tagged with `#important`.

### Save to file

```bash
tag#dev -w example.md
```

Creates `example--tagged--dev.md` with filtered content.

### Piping to other tools

You can pipe output to other commands:

```bash
tag#important example.md | grep "API"
tag#important example.md | wc -l
```

## Examples

Given this markdown file:

```markdown
# Setup Guide #important

Follow these steps carefully.

## Installation #important #setup

Run these commands:

- Install dependencies #important
- Configure settings

## Usage #tutorial

Basic usage instructions here.
```

Running `tag#important example.md` outputs:

```markdown
# Setup Guide #important

Follow these steps carefully.

## Installation #important #setup

Run these commands:

- Install dependencies #important
- Configure settings
```

Note how:
- The `# Setup Guide #important` header includes all its content until the next level-1 header
- The `## Installation #important #setup` header includes its content
- The list item `- Install dependencies #important` is included
- The `## Usage #tutorial` section is excluded (no #important tag)

## How It Works

1. **Tag extraction**: The command `tag#foo` is parsed to extract `foo` as the tag
2. **Element detection**: The awk script identifies markdown elements (headers, lists, paragraphs, code blocks)
3. **Smart inclusion**:
   - Tagged headers include all content in their section (until next same-level header)
   - Code blocks under tagged headers are included
   - Content with different tags under a tagged header is excluded
   - Tagged list items and paragraphs are included entirely
4. **Output**: Filtered content is printed to stdout or written to file

## Limitations #test

- Tags must be in the format `#tagname` (no spaces in tag names)
- Header section filtering stops at the next same-or-higher level header
- Multi-line elements are treated as single units

## License

MIT License - use freely!
