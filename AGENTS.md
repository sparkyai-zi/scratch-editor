# Agent Guide: scratch-editor

## AI-assisted development policy

See [CONTRIBUTING.AI.md](https://github.com/scratchfoundation/.github/blob/main/CONTRIBUTING.AI.md) for Scratch's
org-wide policy on AI-assisted contributions. The short version: human developers remain responsible for all code
they submit. Do not submit code you cannot explain and defend in a review.

## Agent defaults

Use these defaults unless the user asks otherwise:

1. Keep changes minimal and scoped to the user request. Do not refactor surrounding code, add features, or clean up
   style in areas you weren't asked to touch.
2. Do not preserve backward compatibility when it isn't required. When all callers are internal to a package,
   rename or restructure freely. All packages in this repo are published to npm and consumed externally, so treat
   each package's public exports as a contract and preserve compatibility unless explicitly told otherwise.
3. Write comments that explain the current code, not its history. Do not reference prior implementations,
   intermediate states, or what the code "used to do." If an approach seems counterintuitive, explain why it is
   correct now — not why it changed.
4. Prefer fixing root causes over adding surface-level workarounds or assertions.
5. When fixing a bug, start by adding one or more failing tests that reproduce it, then implement the fix. Iterate
   until all tests pass, including but not limited to the new tests. Use the test framework already in use in that
   package — see "Packages at a glance" below.
6. When adding runtime guards for states that should never happen, log actionable context (function name, relevant
   IDs, key flags) rather than failing silently. Use `console.warn` for recoverable states and `console.error` for
   invalid required data.
7. Preserve failure semantics when refactoring. An implicit crash (null dereference, `!` assertion) should become
   an explicit `throw` with a useful message — not silent failure. Code that previously wouldn't crash still
   shouldn't, but consider whether a warning is warranted. Replacing a potential null dereference with
   `if (!foo) return` could make a bug harder to find; `if (!foo) throw new Error(...)` surfaces it.
8. Do not add error handling, fallbacks, or validation for scenarios that cannot happen. Trust internal code and
   framework guarantees. Only validate at system boundaries (user input, external APIs).

## What this repository is

`scratch-editor` is an npm workspaces monorepo containing the packages that make up the Scratch editor. It was
assembled by migrating previously separate repositories into a single repo.

All packages are published to npm under the `@scratch/` scope. They are consumed both internally (e.g.,
`scratch-www` loads `scratch-gui`) and by third parties.

## Build and lint

Run workspace-wide commands from the repo root:

```sh
npm run build    # Build all packages (production)
npm test         # Test all packages
npm run clean    # Clean all packages
```

Run per-package commands from the package directory, or from the root with `--workspace`:

```sh
cd packages/scratch-vm && npm test
# or equivalently:
npm test --workspace=packages/scratch-vm
```

Each package defines its own `test` and `build` scripts; see "Packages at a glance" for specifics.

**Commit messages are enforced.** Husky + commitlint validate every commit against the
[Conventional Commits](https://www.conventionalcommits.org/) format. A commit that doesn't conform will be
rejected by the pre-commit hook.

## Repository layout

```text
packages/
├── scratch-gui/            React-based editor UI
├── scratch-vm/             Virtual machine that runs Scratch projects
├── scratch-render/         WebGL renderer for the stage
├── scratch-svg-renderer/   SVG asset processor
├── task-herder/            Async task scheduler with rate limiting
└── scratch-media-lib-scripts/  Build scripts for media library assets
scripts/                    Monorepo-level utility scripts
```

## Packages at a glance

| Package | Language | Bundler | Tests |
| - | - | - | - |
| `scratch-gui` | JavaScript / JSX (some TypeScript) | webpack | Jest |
| `scratch-vm` | JavaScript | webpack | Tap |
| `scratch-render` | JavaScript | webpack | Tap |
| `scratch-svg-renderer` | JavaScript | webpack | Tap |
| `task-herder` | TypeScript | Vite | Vitest |
| `scratch-media-lib-scripts` | JavaScript | — | Jest |

`task-herder` represents the target stack for new packages (TypeScript + Vite + Vitest). The other packages
reflect the legacy stack and are being migrated incrementally.

## Technology conventions by package

**For existing packages**: follow the conventions already in use in that package — language, bundler, test
framework, and style. Do not introduce TypeScript into a JavaScript package, or Vitest into a Jest package,
unless that migration is the explicit goal of the task.

**For new packages**: follow the org defaults — TypeScript, Vite, Vitest, `eslint-config-scratch`.

All packages use ESLint 9 flat config (`eslint.config.mjs`) with `eslint-config-scratch`. If a package also uses
Prettier (currently `task-herder`), run `npm run format` in addition to lint.

Browser builds target [Baseline Widely Available](https://web.dev/baseline), via the browserslist query
`baseline widely available`. Runtime floors in `packages/scratch-gui/src/lib/supported-browser.js` should match
the core-browser mins of that query.

### scratch-gui specifics

- React functional components with hooks for new code; class components exist in older code.
- Keep components presentational where possible; connect to Redux only in container files.
- Use `react-intl` / `FormattedMessage` for all user-visible strings. Do not hardcode English in JSX.
- After adding or changing messages, run `npm run i18n:src` to update the translation source file.
- Integration tests (`test/integration/`) require a browser environment via Jest + jsdom; they are slow and
  should not be run unnecessarily. Smoke tests (`test/smoke/`) require a live server.

### scratch-vm specifics

- Extension entry points live in `src/extensions/`. Each extension exports a class with `getInfo()` and block
  implementation methods.
- i18n strings in extensions are extracted with `format-message`. Run `npm run i18n:src` after changing them.

## npm workflow

Use `npm ci` from the repo root to install all workspace dependencies from `package-lock.json`.

When adding or updating a dependency in a specific package:

```sh
npm install some-package@version --workspace=packages/scratch-vm
```

This updates both `package.json` in the target package and the root `package-lock.json`.

Keep each section of a package's `package.json` (`dependencies`, `devDependencies`, `scripts`) in alphabetical
order. The same applies to the root `package.json`.

**Do not publish packages manually.** Every package has a `prepublishOnly` script that will error if you try.
Publishing is handled exclusively by the CI release pipeline.

## Before submitting changes

Review all changes and confirm:

- **Scope**: Changes are confined to the user request; nothing extra was added or modified.
- **Correctness**: Logic is sound and edge cases were considered.
- **Comments**: Comments are necessary, short, and clear; self-explanatory code has none.
- **Simplicity**: Implementation is as simple as possible; no speculative abstractions remain.
- **Documentation**: Update `AGENTS.md` and any other documentation files whose content is affected by the change
  (commands, repo structure, conventions, etc.). The "Packages at a glance" table is particularly prone to going
  stale when a package migrates its tooling.
- **Commit format**: Commit message follows Conventional Commits — the husky hook will reject it otherwise.
- **Build passes**: `npm run build` (or `npm run build` in the affected package) completes successfully.
- **Tests pass**: `npm test` (or `npm test` in the affected package) completes with no failures.
- **No lint errors**: `npm run test:lint` (or `npm run lint`) passes in the affected package.

<!-- graft:start -->
## Graft — repo context graph

This repo is indexed in `graft/`: small linked markdown nodes that explain each system and carry exact file:line spans, kept in sync with the code through git.

For ANY task here — understanding how something works, finding where code lives, or scoping a change — get context from the graph before grepping or opening source files. Re-ask freely (it is cheap) and reuse literal identifiers you already have (symbol, error string, file name) as the query. New to this repo? Run `graft map` first — a token-budgeted orientation (dir clusters, hubs, hotspots), no LLM, no key.

- Run `graft ask "<your question>" --source` → ranked nodes with the relevant code spans inlined (each hit's ≤8-line crux by default; `--full` for whole definitions when the crux isn't enough). Match the tool to the task shape: for understanding or editing, the top node IS the answer — cite its `covers:` file:line spans and edit straight from `--source`. For exhaustive tasks ("every occurrence / every caller of this pattern"), ranked results are top-N, not complete — run `graft grep "<literal>"` instead (exhaustive over indexed files, grouped by enclosing symbol), falling back to raw `grep -rn` only for unindexed files.
- `graft skeleton <file>` → every definition's signature + span, ~10× cheaper than reading the file; use it to skim an API surface.
- `graft callers <symbol>` gives precomputed, exact edges — who calls this. Add `--direction out` for what it calls, or `--depth N` to walk transitively for the full blast radius. For structural questions, skip ranking and use this directly.
- Or browse: `graft/INDEX.md` lists every node; follow the links.
- Monorepos and folders of multiple repos rank fairly across sub-projects — hits carry `[scope/]` labels naming which one they're from. Narrow with `graft ask "<task>" --in <scope>/` once you know where you are working.

If a returned span is truncated ("+N more lines"), open the file at that exact range before finalizing. Only open source files when a node genuinely lacks a needed detail, and then at the exact file:line the node points to — never re-read whole files.

After big code changes, refresh the graph with `graft build` (deterministic, no API key, $0).
<!-- graft:end -->
