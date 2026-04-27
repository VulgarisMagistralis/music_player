# Music Player Project

## Coding Preferences

### Bug Fixes
- Always attempt minimal changes first before rewriting entire files
- Identify the specific problematic line(s) and fix only those
- Preserve existing patterns, variable names, and structure unless they are the cause of the bug

### General Approach
- Read the affected file first before making changes
- When a widget throws a layout error, check the widget hierarchy and constraint conflicts
- Flutter layout issues often stem from `width: double.infinity` or similar infinite constraints inside scrollable/Expanded contexts
