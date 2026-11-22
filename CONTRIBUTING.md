# Contributing

This repository is the Homebrew tap for
[Braveheart](https://github.com/Braveheart-Chess/braveheart), the UCI chess
engine. Engine changes belong in the engine repository; how Homebrew installs
the engine belongs here.

## Setup

```sh
npm ci                                                          # commitlint
pre-commit install --hook-type commit-msg --hook-type pre-commit
```

The hooks are a convenience. CI is the authoritative check.

## Checks

| CI job | What it runs | Locally |
| --- | --- | --- |
| `Commit messages` | commitlint over every commit in `base..head` | `npx commitlint --from origin/main --to HEAD --verbose`, then `npm run test:commitlint` |
| `PR title` | The title passes commitlint, scope included | |
| `Formula (macOS arm64)`, `Formula (macOS Intel)`, `Formula (Linux x86-64)`, `Formula (Linux ARM)` | `brew install`, `brew test`, `brew linkage --test` and `brew audit --strict --online` on that platform | [Testing a formula change](#testing-a-formula-change) |
| `Formula style` | `brew style`, and `brew readall` on every OS and architecture | `brew style --formula braveheart-chess/tap/braveheart` |

## Testing a formula change

Tap your branch under the real tap name, install from it, and remove it
afterwards so that your Homebrew goes back to the published tap:

```sh
brew untap braveheart-chess/tap 2>/dev/null   # if you use the published tap
brew tap braveheart-chess/tap "$PWD"          # clones the branch's last commit
brew install braveheart-chess/tap/braveheart
brew test braveheart-chess/tap/braveheart
brew audit --strict --online --formula braveheart-chess/tap/braveheart
brew style --formula braveheart-chess/tap/braveheart
brew readall --os=all --arch=all braveheart-chess/tap
brew uninstall braveheart && brew untap braveheart-chess/tap
```

`brew audit --os=linux --arch=arm` (and the other combinations) checks a
platform you are not on. CI runs the install and the test on all four.

## Commit messages

Every commit is a **single-line** [Conventional Commit](https://www.conventionalcommits.org/) with a type and a scope:

```
type(scope): subject
```

- At most 100 characters, with an imperative, lowercase subject and no trailing period.
- `type` is one of `feat`, `fix`, `perf`, `revert`, `docs`, `refactor`, `test`, `build`, `ci`, `style`, `chore`: the same set in every repository.
- `scope` is required: exactly one of the scopes below. A change that spans two is two pull requests, or takes the scope it is mostly about.
- Breaking changes are marked with `!`, for example `feat(formula)!: rename the formula to braveheart-engine`.
- The only content allowed after the header is a blank line followed by `Co-authored-by: Name <email>` trailers, in any letter case. No body text. Details belong in the PR description.
- The type drives the next version: `feat` bumps the minor version, `fix` the patch, and `!` the major (the minor while the version is below 1.0).

| Message | Valid |
| --- | --- |
| `feat(formula): update braveheart to 0.55.0` | Yes |
| `fix(formula): run the test on Linux too` + blank line + `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` | Yes |
| `feat: update braveheart to 0.55.0` | No, no scope |
| `feat(nope): update braveheart to 0.55.0` | No, not one of this repository's scopes |
| `feat(formula): update braveheart to 0.55.0` + blank line + `This adds…` | No, body text |

commitlint enforces this with `@commitlint/config-conventional` plus two local rules in `tools/commitlint/`: `only-coauthor-trailers` fails on any line after the header that is not blank or a `Co-authored-by` trailer, and `single-scope` fails on a list such as `feat(a,b)`. The fixtures in `tests/commitlint/` show accepted and rejected messages. CI lints every commit in the PR range, so a rebase merge never lands a non-conforming commit on `main`, and lints the PR title through the same config. The standard behind it is the [repository conventions](https://github.com/jwallace145/repository-template/blob/main/repository-conventions.md).

### Scopes

Every commit names exactly one of this repository's scopes. They are `SCOPES` in `commitlint.config.mjs`; this table mirrors it, in the same order, and `npm run test:commitlint` fails if they drift. Adding, renaming or removing a scope goes through a pull request like any other change.

| Scope | Covers |
| --- | --- |
| `formula` | The formulae in `Formula/` and the jobs that test them |
| `repo` | README, CONTRIBUTING, AGENTS, commitlint, the PR and issue templates, and repository tooling |
| `deps` | Dependency updates, mostly Dependabot's |
| `release` | Release Please's release pull requests and its config |

## Pull requests

Every change reaches `main` through a pull request. Nobody pushes to `main`.

- The title is a valid commit header, scope included: squash merges use it as the commit message. Release Please's own pull requests are titled `chore(release): release X.Y.Z`.
- Fill in every section of the one template, `.github/pull_request_template.md` (Summary, Why, Changes, Verification, Checklist). Write "n/a" rather than deleting one.
- Pull requests merge by squash or rebase only. There are no merge commits.
- Dependabot's titles are `chore(deps): bump ...` and pass as they are; squash merge them.

## Issues

Open issues from the forms: **Bug**, **Feature** or **Task**. Blank issues are off.
## Releases

[Release Please](https://github.com/googleapis/release-please) keeps a release
pull request open with the next version and the changelog. Merging it tags the
version. It owns `CHANGELOG.md`; nobody edits that file by hand.

Homebrew reads the formula from `main`, so users get a change as soon as its
pull request merges. A release of this repository is a record of what the tap
has shipped, not a gate in front of it.

The release pull request is authored by the `braveheart-chess-release-bot`
GitHub App, the organisation's release bot, so CI runs on it. The workflow
reads the app's credentials from the secrets `RELEASE_BOT_CLIENT_ID` and
`RELEASE_BOT_PRIVATE_KEY`.
