# Guidance for coding agents

This repository is the Homebrew tap for
[Braveheart](https://github.com/Braveheart-Chess/braveheart), the UCI chess
engine. Read [README.md](README.md) for what the tap is and
[CONTRIBUTING.md](CONTRIBUTING.md) for the full rules. The rules below are the
ones you MUST follow.

## Rules

- **Never push to `main`.** Every change goes through a pull request on a branch.
- **Commits are a single line**: `type(scope)?: subject`, at most 100 characters.
  Allowed types: `feat`, `fix`, `docs`, `chore`, `refactor`, `ci`, `build`, `perf`, `style`, `test`, `revert`.
  The only thing allowed after the header is a blank line and
  `Co-authored-by: Name <email>` trailers. No body text. Put details in the PR description.
- **Open PRs with a typed template** and fill in every section:

  ```sh
  gh pr create --template <feat|fix|docs|chore|refactor|ci>.md
  ```

  The PR title MUST be a valid Conventional Commit; squash merges use it as the commit message.
- **Merges are squash or rebase only.** Never create merge commits.
- **Run the repo's checks locally before opening the PR** (see below).
- **Engine changes belong in the engine repository.** This repository only
  packages what the engine releases.
- **The install command is a contract.** People run
  `brew install braveheart-chess/tap/braveheart` and later `brew upgrade`.
  Never rename the formula or this repository, or drop a platform, without
  the owner's say-so; when it does happen it is a breaking change (`feat!:`).
- **Checksums come from the release.** A `sha256` in the formula is the hash
  of the exact file its `url` downloads, checked against the `.sha256` file
  the engine's release workflow attached. Never type one in from anywhere else.
- **Every platform stays tested.** A formula change passes the `Formula` job
  on all four runners; don't skip one or mark it optional.
- **`CHANGELOG.md` is Release Please's.** Never edit it by hand.

## Before opening a PR

```sh
npm ci
npx commitlint --from origin/main --to HEAD --verbose
pre-commit run --all-files
```

For a formula change, test the branch through a local tap (see
[CONTRIBUTING.md](CONTRIBUTING.md#testing-a-formula-change)), then untap it.

## Things that need the owner

Repository settings and secrets, the release bot, and merging the Release
Please PR. List them in the PR instead of attempting them.
