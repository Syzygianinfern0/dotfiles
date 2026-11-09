---
name: netlify-publish
description: Publish a static page or folder (often an HTML page first built as a claude.ai artifact) to a public Netlify URL from the command line, and redeploy it later to the same URL. Use when the user asks to put something on Netlify, wants a public link that anyone can open, or a claude.ai artifact can't be shared publicly (UT Austin's org blocks public artifact links). Not for sites that need a build step or server code.
---

# Netlify publish

Deploy headlessly with the Netlify CLI. Don't use browser automation or drag-and-drop.

## Before you start

- **This makes a public page.** Anyone with the URL can open it, and it may be cached or indexed. Make sure the user asked
  for a public link, and point out anything personal on the page (addresses, hotel names, dates, emails) before deploying.
- **The CLI.** Run it as `npx --yes netlify-cli ...`, with no global install. In a fresh shell, load nvm first if `npx`
  isn't on PATH: `export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh"`. In a sandbox, Netlify's API calls need network
  access.
- **Login.** Check with `npx --yes netlify-cli status`. If it isn't logged in, the user has to run
  `npx netlify-cli login` themselves, because it opens a browser. The auth token is stored in the CLI's own config
  (on macOS, `~/Library/Preferences/netlify/config.json`). Never copy the token into dotfiles, repos or notes.

## Publish a new site

1. **Make a folder with an `index.html`.** Put it inside the project's folder: the directory the session was started from,
   or a subfolder of it (for example `<project>/site/`). Never use `~/Downloads` or a temp/scratch directory, since the
   folder has to stick around for later redeploys.
   If the HTML came from a claude.ai artifact, it's only a page *fragment*: the artifact host adds the
   `<!doctype html>`, `<head>` and `<body>` itself. Netlify doesn't, so wrap the fragment:
   ```html
   <!doctype html><html lang="en"><head><meta charset="utf-8">
   <meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
   <style>:root{box-sizing:border-box;padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}body{margin:0}img{max-width:100%}[hidden]{display:none!important}</style>
   </head><body>
   <!-- artifact HTML here -->
   </body></html>
   ```
   Pages that call `window.claude.*` artifact APIs (shared storage, asking Claude, and so on) won't work on Netlify.
   Tell the user which features will be missing.
2. **Create the site.** This runs without prompts, and with a single team it picks that team:
   `npx --yes netlify-cli sites:create --name <unique-name> --disable-linking`
   Record the **Project ID** it prints.
3. **Deploy:**
   `npx --yes netlify-cli deploy --no-build --dir <folder> --prod --site <project-id>`
   `--no-build` stops it from looking for a build step. `--prod` publishes to the main URL rather than a draft URL.
4. **Check it.** Confirm `curl -s -o /dev/null -w "%{http_code}\n" https://<name>.netlify.app/` returns `200`.

## Update an existing site

Rebuild the folder, then run the same `deploy` command with the same `--site <project-id>`. The URL stays the same. If the
page also exists as an artifact, update both; they're separate copies.

## Gotchas

- `--site` needs the **ID**, not the site name; the name returns "Not Found". List IDs with
  `npx --yes netlify-cli sites:list --json`.
- Without `--disable-linking`, `sites:create` writes a `.netlify/` folder into the current directory.
- Keep everything self-contained (inline CSS/JS, or files in the deploy folder). Netlify serves any static files, but a
  page copied from an artifact may still assume the artifact's CDN allowlist. That's harmless here.

## Remember the site

Once a site is created, record its name, project ID, URL and source folder where the next session will find them: the
project's own notes or README, or the agent's memory for that project. Without the ID, a later redeploy can't target the
same URL.
