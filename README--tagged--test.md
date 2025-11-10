### For Bash #test
Add to your `~/.bashrc`:

```bash
source /path/to/markdown-tag-filter.sh
```

Then reload:

```bash
source ~/.bashrc
```

## Limitations #test

- Tags must be in the format `#tagname` (no spaces in tag names)
- Header section filtering stops at the next same-or-higher level header
- Multi-line elements are treated as single units

