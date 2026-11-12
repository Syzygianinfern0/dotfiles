---
name: imagegen
description: Generate illustrative images with hosted image models (OpenAI gpt-image, Gemini "Nano Banana") through ~/bin/imagegen — slide visuals, paper teasers, concept art, scene illustrations, restyling a render or photo. Use when the user asks for an AI-generated image, picture or illustration, or for a visual that only pixels can give (a photoreal scene, an artistic hook image). Not for plots, charts, tables, pipeline or architecture diagrams, timelines or anything with exact numbers or many labels — draw those with code (matplotlib, SVG, TikZ, Mermaid) instead.
---

# Image generation

`imagegen` batch-calls OpenAI and Gemini image models in parallel, saves every variant, records the exact prompt and
model in a manifest, and builds a contact sheet so the user can pick winners. Run `imagegen --help` for every flag.

## Decide first: image model or code?

Image models are good at scenes, mood, styles and loose concept illustrations. They invent details, misspell longer
text and can't keep exact structure. So:

- **Use imagegen** for hook or teaser images, "what this looks like" scenes, stylised illustrations of an idea or a
  failure mode, backgrounds, and restyling an existing render or photo (`refs`).
- **Use code** for plots, charts, tables, flowcharts, pipeline or architecture diagrams, timelines, and anything a reader
  will read numbers or labels off. A mixed figure is often best as a generated image with labels added afterwards in code
  or in the slide tool.
- **Never present a generated image as data or results.** Tell the user to caption it as an illustration, especially if
  it depicts something the project measures (e.g. "views disagree", "the model fails here").

## Keys

The script reads `OPENAI_API_KEY` and `GEMINI_API_KEY` (or `GOOGLE_API_KEY`) from the environment, else from
`~/.config/imagegen.env` (`KEY=VALUE` lines, mode 600). If both are missing, ask the user to create that file
themselves; never ask them to paste keys into the chat, and never print, cat or echo the file. A backend without a key
is skipped.

## Workflow

1. **Write a prompts YAML** in the project (e.g. `figs/prompts/<topic>.yaml`), one entry per figure:
   ```yaml
   defaults: {aspect: "16:9", n: 2}
   figures:
     - id: teaser
       note: slide 3 hook            # shown on the contact sheet
       prompt: |
         ...
       style: Photorealistic, natural lighting.
       refs: [../renders/scene.png]  # optional: restyle / edit this image
   ```
   For a single image, skip the YAML: `imagegen -p "..." --id name [--ref img.png] [--aspect 1:1]`.
2. **Dry run** to check the job count: `imagegen <yaml> --dry-run`. The default is both backends × `n` variants per
   figure. Each image costs roughly $0.05–0.30, so for big batches (>30 images) say the count and rough cost first.
3. **Run it**: `imagegen <yaml>`. Output goes to `<yaml dir>/imagegen-out/<yaml name>/` unless `--out` is given.
   In a git repo, put that directory in `.gitignore` or point `--out` at the project's data/output directory, so
   images aren't committed by accident.
   Each run ends with an estimated cost (this run and the whole manifest), and every image's token usage and
   `est_cost_usd` are in `manifest.json`. Estimates come from the `PRICES` table in the script, so models missing
   from it are logged without a cost. Report the estimate to the user.
4. **Look at the contact sheet** (`contact_sheet.png`) yourself before reporting, and check each candidate image at full
   size for garbled text, wrong counts, broken objects or anything that contradicts the prompt. Report which variants
   work and why, with paths, and fix the prompt for the ones that don't.
5. **Iterate**: edit the prompt, delete the bad variants (or use a new `id`) and re-run. Existing files are kept, so a
   re-run only fills the gaps; `-n` raises the variant count and `--only id1,id2` limits the run.

## Prompting tips

- Describe the scene concretely: subjects, colours, positions, camera, lighting, style. Spell out what must stay the same
  across panels.
- **Several views of one thing go in one image** (a 2×2 grid with labelled panels). Separate generations won't agree on
  colours and layout.
- Keep text in the image to a few short labels in quotes ("CCTV"). Anything longer, add later.
- Flat vector / isometric styles on a white background drop into slides more cleanly than photoreal.
- The two backends differ: run both at first and keep whichever wins for each figure.

## Models

Defaults are set at the top of the script (`DEFAULT_MODELS`). Model ids change often; `imagegen --list-models` shows what
the keys can use, and `--openai-model` / `--gemini-model` override for one run. If a default stops working, update it
in the dotfiles source (`bin/executable_imagegen`), not the deployed copy.

## Errors

Failures are recorded per image in `manifest.json` (`status: error`) and the run carries on. Safety refusals aren't
retried; rephrase the prompt (real people, brands and violent detail are the usual triggers).
