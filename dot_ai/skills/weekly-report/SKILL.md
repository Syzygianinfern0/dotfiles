---
name: weekly-report
description: Write the user's one-page LaTeX weekly report for their advisor, covering one project or several, for a given week (default the last full Monday-Sunday week). Gathers the week's work from git history, findings docs and past agent sessions, writes two plain-language paragraphs and one figure, and compiles it in ~/code/weekly-reports. Use when the user asks for a weekly report, advisor update or "report for last week", or invokes weekly-report.
---

# Weekly report

A one-page PDF for the user's advisor: a header, at most two paragraphs, one figure. The reader may not know the project, so it reads from the top without context and isn't very technical.

## Inputs

- **Week.** Monday to Sunday. Default: the last full week before today. The report is named and dated by that Monday.
- **Projects.** One or more repos. If the user didn't name them, list repos with commits or agent sessions in the week (see step 1) and ask which to include.
- **Author** for the header: `S P Sharan` unless the user says otherwise.
- **Collaborators.** Leave collaborators' names out of the report unless the user asks for them ("we tested..."). If a collaborator wrote their own report for the same week, keep the numbers consistent with it, don't reuse their figure, and put the weight on the user's own part of the work.

## Where things go

Reports live in the git repo `~/code/weekly-reports`, one folder per week:

```
~/code/weekly-reports/
  2026-11-09/            ← Monday of the covered week
    2026-11-09_SP-Sharan_weekly-report.tex  (and .pdf)
    figure.pdf  make_figure.py   ← script names its data sources in a comment
    sources.md                   ← what the report was built from (see step 2)
```

If the repo doesn't exist, create it (`git init`, a `.gitignore` with `build/` and LaTeX aux files). Name the report `<Monday>_<Author with spaces as hyphens>_weekly-report` (`.tex` and `.pdf`), for example `2026-11-09_SP-Sharan_weekly-report.pdf`, so the file still says what it is when it's attached to an email; a variant adds a suffix (`..._weekly-report_slides-figure.pdf`). Start each week from `assets/report.tex` in this skill's folder. Look at one or two recent weeks to match tone and length.

## Steps

1. **Find the week's work** for each project. Use a fresh subagent per project when the agent can, so the raw logs stay out of the main context:
   - `git -C <repo> log --all --since=<Mon> --until=<next Mon> --stat`
   - findings, notes and results docs created or changed that week, and the repo's README or agent instructions for background
   - past agent sessions from that week, from both agents: Claude Code in `~/.claude/projects/<repo path with / as ->/*.jsonl`, Codex in `~/.codex/sessions/YYYY/MM/DD/*.jsonl` (first line's `payload.cwd` is the repo). Read one with `chat2md <session-id>` run from the repo. Transcripts are per machine; if the project ran elsewhere, say so to the user.
   - meeting slides or docs the user links (read them with a Google Drive or docs connector). Slides from a group meeting that week usually hold the story the user wants told.
   - collaborators' copies of the project. Ask the user who else ran experiments, find their home directory (`getent passwd | grep -i <name>`) and read their project docs and results. Never read their `~/.claude`, `~/.codex` or other private agent histories.
   - Note what was started or finished outside the week, so the report doesn't credit it to this week.
2. **Pick the story, then check it with the user.** One headline result per project, plus the next step. Next steps come from what the user said or wrote, never invented. Before writing any LaTeX, tell the user what you plan to include: the headline, the points for each paragraph, what the figure will show, and what you're leaving out. Wait for their go-ahead. Then write `sources.md`: for every number in the report, the file or session it came from.
3. **Make the figure.** Make a new figure rather than pasting a slide or a collaborator's figure. Show the point directly. One figure, about 7 x 2.5 in, from a script (`make_figure.py`, run with `uv run`) that reads the results files and names them in a comment. Reuse an existing project plot only if it is readable at that size and in plain terms. For several projects: one panel per project with the project name as the panel title, or a figure from the main project only.
4. **Write.** Fill the week's `.tex` file:
   - Header: `Week of <Month D, YYYY>` and, on the right, `<Project>: <the week's question>`. For several projects, name them all or give a shared theme.
   - Paragraph 1: what the project is, the problem, what we tried. Paragraph 2: what we found (cite `Figure~\ref{fig:main}`) and the next step.
   - Several projects: still two paragraphs, one per project, each opening with a bold run-in project name (`\textbf{VSeek.}`) and a sentence of background.
   - Plain words for internal names ("the agent that keeps text notes", not `clipmem_text`). Only the numbers that carry the point. Spell out an abbreviation the advisor may not know, or drop it.
   - Length: text plus figure should fill at least three-quarters of the page (about 350–400 words of text with a figure about 2.5 in tall). A 180-word version was judged too empty. Add context (setup, the full range of results, why the next direction matters) rather than padding, and keep it plain.
   - Caption: what the colors and groups are, in plain words. No model sizes or benchmark sizes.
5. **Compile and check.** `latexmk -pdf -outdir=build <name>.tex && cp build/<name>.pdf . && rm -rf build`, then `pdfinfo <name>.pdf` must say 1 page. If it's over, cut text; never shrink margins, font or figure to fit. Look at the rendered page before handing it over.
6. **Hand over.** Give the PDF path, a few lines on what each paragraph says, and anything you were unsure of (work from outside the week, a guess at the next step). Don't commit unless asked.

## Changing the format

The user's preferences so far: the plain layout in `assets/report.tex` (they picked it over a headline-first and a side-by-side layout), plain wording that still fills most of the page, and the next step stated at a high level. When they ask for a lasting format change, update this file and the template, not just that week's report.
