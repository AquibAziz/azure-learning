# 📝 Note-taking conventions

Rules I follow so this repo stays useful as it grows.

## Folder & file naming

- Lowercase, hyphenated: `vnet-subnets.md` not `VNet_Subnets.md`
- Numbered prefixes for ordered content: `01-vnet-subnets.md`, `02-nsg-asg.md`
- Course folders: `<platform>-<instructor-or-course-short-name>/` — e.g., `youtube-abhishek-zero-to-hero/`
- Lab folders: `lab-<nn>-<short-name>/` — e.g., `lab-01-first-vm/`

## Note file structure

Every fundamentals note follows this template:

```markdown
# Topic Name

> One-sentence summary of what this topic is and why it matters.

## Why it exists
[The problem this concept solves]

## Core concepts
[The main ideas, explained simply]

## How it works
[Mechanics, with examples]

## Common patterns
[How it's used in real-world architectures]

## Gotchas & exam tips
[Things that catch people out]

## Related topics
[Links to other notes in this repo]

## Sources
[Courses, docs, videos I learned this from]
```

## Course log structure

Every course day/session log follows this template:

```markdown
# [Course] - Day N: Topic

**Date watched:** YYYY-MM-DD
**Video link:** <url>
**Duration:** X min

## Key concepts covered
[Bullet list]

## My notes
[Raw notes — messy is fine here]

## Questions that came up
[Things I want to dig into later]

## Links to canonical notes
[Pointers to 01-fundamentals/ files I updated or created]
```

## Lab write-up structure

```markdown
# Lab NN: Short description

## Goal
[What I'm trying to learn/build]

## Architecture
[Diagram or description]

## Steps
[Numbered, with commands]

## Gotchas
[What broke, what I had to fix]

## Cleanup
[az group delete commands so I don't burn credits]

## What I learned
[Key takeaways]
```

## Git commit messages

- `notes: add VNet fundamentals`
- `course: add day 5 youtube-abhishek`
- `lab: complete lab-02 VNet peering`
- `fix: correct NSG priority explanation`
- `cheat: add az-cli networking commands`

## Keeping it sustainable

- **Don't over-edit.** Course notes stay raw. Only fundamentals get polished.
- **Link, don't duplicate.** If a concept lives in `01-fundamentals/`, course notes link to it.
- **Update the root README's progress tracker** when you finish a note or topic.
- **Commit often.** Small commits make progress visible and reversible.
