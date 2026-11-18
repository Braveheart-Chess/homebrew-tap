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
| `Commit messages` | commitlint over every commit in `base..head` | `npx commitlint --from origin/main --to HEAD --verbose` |
| `PR title` | The title is a Conventional Commit | |

## Commit messages

Every commit is a **single-line** [Conventional Commit](https://www.conventionalcommits.org/)
of at most 100 characters. Details go in the pull request description, never in a commit body.

- Format: `type(scope)?: subject`, with an imperative, lowercase subject and no trailing period.
- The only thing allowed after the header is a blank line followed by
  `Co-authored-by: Name <email>` trailers.
- Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `ci`, `build`, `perf`, `style`, `test`, `revert`.
- A breaking change is marked with `!`, as in `feat!: rename the formula to braveheart-engine`.
- The type drives the next version: `feat` bumps the minor version, `fix` the patch,
  and `!` the major (the minor while the version is below 1.0).

| Message | Valid |
| --- | --- |
| `feat(braveheart): update to 0.55.0` | Yes |
| `fix(braveheart): run the test on Linux too` + blank line + `Co-authored-by: Claude <noreply@anthropic.com>` | Yes |
| `feat: add thing` + blank line + `This adds the thing because…` | No, body text |
| `Added thing` | No, not conventional |

CI lints every commit in the pull request, and the pull request title separately.

## Pull requests

Every change reaches `main` through a pull request. Nobody pushes to `main`.

- The title is a valid Conventional Commit: squash merges use it as the commit message.
- Open the pull request with a typed template and fill in every section:

  ```sh
  gh pr create --template <feat|fix|docs|chore|refactor|ci>.md
  ```

- Pull requests merge by squash or rebase only. There are no merge commits.

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
