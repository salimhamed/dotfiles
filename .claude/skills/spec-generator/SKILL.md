---
name: spec-generator
description: Generate detailed implementation specs for projects with "Spec Status" set to "Queue" in the Notion Project Tracker. Use when the user wants to create specs, plan projects, or says "generate specs".
allowed-tools:
  - mcp__claude_ai_Notion__notion-search
  - mcp__claude_ai_Notion__notion-fetch
  - mcp__claude_ai_Notion__notion-update-page
  - mcp__claude_ai_Notion__notion-update-data-source
  - Bash(mkdir *)
  - Write
  - Read
  - Glob
  - Grep
---

# Spec Generator

Generate detailed implementation specs from the Notion Project Tracker.

## Workflow

### Step 1: Fetch queued items

Find all Project Tracker items with **"Spec Status"** set to **"Queue"**.

**Important:** The database has two similarly-named properties — "Status" (workflow status: Not started / In progress / Done) and "Spec Status" (spec generation trigger: Queue / Done). Only the **"Spec Status"** property controls this skill. Ignore the "Status" property entirely.

1. Use `notion-search` with a broad query (e.g., `" "`) scoped to the data source `collection://300c7bb8-aef1-8075-8429-000b28262f1f`. This returns pages from the database ranked by relevance.

2. For each page URL returned by search, use `notion-fetch` to get the full page. The response includes a `<properties>` tag containing JSON like:
   ```
   {"Category":"Claude Code","Name":"Daily AI Meeting Bot","Spec Status":"Queue","Status":"Not started",...}
   ```
   Check this JSON for the key **`"Spec Status"`** (not `"Status"`) with value **`"Queue"`**. If "Spec Status" is not present in the JSON, the property is unset — skip that page.

3. Collect all pages where `"Spec Status" = "Queue"` into a work list. Also capture the page URL and properties (Category, Name, Priority, Size) from this same fetch — no need to re-fetch in step 2a.

If no items have Spec Status = Queue, report "No items queued for spec generation" and stop.

### Step 2: Process each queued item

For each item in the work list:

#### 2a. Extract project details

The `notion-fetch` response from Step 1 already contains everything needed — no need to re-fetch. Extract from the cached response:
- **Properties** (from `<properties>` JSON): Name, Category, Priority, Size
- **Page content** (from `<content>` section): Goal, Requirements, Acceptance Criteria
- **Page URL** — the Notion page URL used to fetch

#### 2b. Determine paths

- **Category slug**: Convert the Category field to kebab-case lowercase (e.g., "Claude Code" → `claude-code`, "Dev Workflow" → `dev-workflow`)
- **Project slug**: Convert the Project Name to kebab-case lowercase, removing special characters (e.g., "AI Email Server Setup" → `ai-email-server-setup`)
- **Output dir**: `~/spec/projects/<category-slug>/<project-slug>/`
- **Output path**: `~/spec/projects/<category-slug>/<project-slug>/spec.md`

Create the project directory if it doesn't exist:
```bash
mkdir -p ~/spec/projects/<category-slug>/<project-slug>
```

#### 2c. Research (when needed)

If the project involves existing code, tools, APIs, or frameworks:
- Use Explore agents to investigate relevant codebases
- Use web search to look up APIs, libraries, or services mentioned in the requirements
- Gather enough context to write technically specific implementation steps

Skip deep research for simple or self-contained projects.

#### 2d. Generate the spec

Write a comprehensive spec using this template:

```markdown
# <Project Name>

> Category: <Category> | Priority: <Priority> | Size: <Size>
> Source: <Notion URL>
> Generated: YYYY-MM-DD

## Overview
What this project does and why it matters. 1-2 paragraphs.

## Goals
- Primary goal
- Secondary goals

## Technical Design

### Architecture
How the system fits together. Components, data flow, integration points.

### Key Decisions
Important technical choices and their rationale.

### Dependencies
External tools, APIs, packages, or services required.

## Implementation Plan

### Phase 1: <Name>
- [ ] Step with detail
- [ ] Step with detail

### Phase 2: <Name>
- [ ] Step with detail

(Scale phases to Size — S=1 phase, M=2 phases, L=3+ phases)

## File Structure
```
project-root/
├── file1
└── file2
```

## Testing Strategy
How to verify the implementation works.

## Risks & Open Questions
- Known risks
- Things to figure out during implementation

## Acceptance Criteria
Carried over from Notion + expanded with technical criteria.
```

**Writing guidelines:**
- Be specific and actionable — someone should be able to start coding from this spec
- Include real file paths, command examples, and API endpoints where known
- The Overview should explain *why* this project matters, not just *what* it does
- Implementation steps should be concrete tasks, not vague descriptions
- Scale detail to project Size: S gets a focused single-phase plan, L gets thorough multi-phase breakdown
- Set `Generated:` to today's date (YYYY-MM-DD format)

#### 2e. Save the spec

Use the Write tool to save the spec to the output path determined in step 2b. If the project directory already exists (re-spec), only overwrite `spec.md` — do not delete or modify any other files in the directory (the user may have added notes, context, or scratch files).

#### 2f. Set Spec Status to Done

Use `notion-update-page` with `command: "update_properties"` to set the "Spec Status" property to "Done":
- page_id: the Notion page ID
- properties: `{"Spec Status": "Done"}`

This prevents the item from being picked up on the next run. To re-generate a spec, the user sets Spec Status back to "Queue" in Notion.

### Step 3: Report

After processing all items, print a summary:

```
## Specs Generated

| Project | Path |
|---------|------|
| <Name>  | ~/spec/projects/<category>/<slug>/spec.md |
| ...     | ... |

Generated <N> spec(s).
```

If any items failed, list them separately with the reason.
