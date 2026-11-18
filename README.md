<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/Braveheart-Chess/braveheart-branding/main/banner-dark.png">
    <img src="https://raw.githubusercontent.com/Braveheart-Chess/braveheart-branding/main/banner-light.png" alt="Braveheart" width="640">
  </picture><br>
  <sub>Logo © the artist, used under licence. All rights reserved; not covered by this repository's licence (<a href="https://github.com/Braveheart-Chess/braveheart-branding#licence">details</a>).</sub>
</p>

# Braveheart for Homebrew

One command puts [Braveheart](https://github.com/Braveheart-Chess/braveheart),
a UCI chess engine in Rust, on your `PATH`, ready for any chess GUI:

```sh
brew install braveheart-chess/tap/braveheart
```

Braveheart is alpha-beta search and an NNUE trained on 3.0 billion positions
from its own self-play ([the net's record](https://github.com/Braveheart-Chess/braveheart-trainer/blob/main/docs/nets.md#net8x160-l050-r43390801430)),
and every change to it is measured before it ships: perft for correctness,
bench for speed, SPRT for Elo. Its
[v0.54.0 release](https://github.com/Braveheart-Chess/braveheart/releases/tag/v0.54.0)
is estimated at **~3221 ± 30** on Stockfish's `UCI_Elo` scale at 10+0.1, from
400 games against Stockfish 19 at four strength levels (a ballpark scale, not
a CCRL rating).

The formula installs the engine's own release binaries, the same files
attached to each GitHub release, with the net embedded. Nothing compiles on
your machine and nothing else downloads. The tap's CI installs and tests the
formula on four platforms before any change reaches `main`.

## Install

```sh
brew install braveheart-chess/tap/braveheart   # install
brew upgrade braveheart                        # a newer engine release
brew uninstall braveheart                      # remove
```

Naming the formula with its tap (`braveheart-chess/tap/braveheart`) taps this
repository and tells Homebrew to trust the formula, in one step. If you tap
first with `brew tap braveheart-chess/tap` and then run
`brew install braveheart`, Homebrew asks you to run
`brew trust braveheart-chess/tap` before it will load the formula.

## Try it

```sh
braveheart --version         # the release you installed
braveheart perft --depth 5   # 4,865,609 leaves from the starting position
braveheart bench             # the node signature, and your machine's speed
printf 'uci\nposition startpos\ngo depth 12\n' | braveheart
```

`bench` searches 50 fixed positions and prints a node signature that is the
same on every machine: 919,304 for v0.54.0, the number in that release's
notes. Each release's notes list its signature, so a matching number shows
the engine you installed is the one that was measured.

### Talk to it in UCI

With no command, `braveheart` speaks
[UCI](https://backscattering.de/chess/uci/), the text protocol chess GUIs use
to drive an engine. Run `braveheart` on its own and type these lines, or pipe
them in as the last command above does; when its input ends, it finishes the
search it is on and exits.

```text
uci
setoption name Hash value 64
isready
ucinewgame
position startpos moves e2e4 e7e5 g1f3 b8c6 d2d4
go depth 16
quit
```

| Line | What it does |
| --- | --- |
| `uci` | It names itself, lists its options, and answers `uciok`. |
| `setoption name Hash value 64` | A 64 MB hash table (the default is 16). |
| `isready` | Answers `readyok` once it is set up. |
| `ucinewgame` | Forgets the previous game. |
| `position startpos moves …` | The starting position (or `fen <FEN>`), then the moves played since, in long algebraic notation: `e2e4`, `e1g1` to castle, `e7e8q` to promote. |
| `go depth 16` | Searches 16 moves deep. |
| `quit` | Exits. |

The position is the Scotch (1. e4 e5 2. Nf3 Nc6 3. d4), Scotland's own
opening. The search prints one `info` line per depth and ends with the
engine's move and the reply it expects (v0.54.0's output; the timings depend
on your machine):

```text
info depth 16 score cp -43 nodes 367377 nps 2007524 time 183 pv e5d4 f3d4 g8f6 d4c6 b7c6 f1d3
bestmove e5d4 ponder f3d4
```

The score is in centipawns for the side to move: Black is 0.43 pawns worse,
the usual small edge for White. `pv` is the line it expects: 3...exd4
4. Nxd4 Nf6 5. Nxc6 bxc6 6. Bd3. Other ways to limit a search:

| Command | Searches |
| --- | --- |
| `go depth 14` | to a fixed depth |
| `go movetime 2000` | for 2,000 ms |
| `go wtime 60000 btime 60000 winc 1000 binc 1000` | as if playing a 1+1 game, budgeting its own time |
| `go infinite` | until you send `stop` |

### Play it in a GUI

To play it in a
GUI such as [Cute Chess](https://github.com/cutechess/cutechess),
[En Croissant](https://encroissant.org/) or
[BanksiaGUI](https://banksiagui.com/), add a UCI engine and point it at the
path `which braveheart` prints (`/opt/homebrew/bin/braveheart` on Apple
silicon). Its options are `Hash` (MB), `Move Overhead` (ms), `Ponder` and
`EvalFile`.

## Platforms

| Platform | What Homebrew installs | CPU it needs |
| --- | --- | --- |
| macOS, Apple silicon | the release binary | any Apple silicon Mac |
| macOS, Intel | the release binary | x86-64-v3 (AVX2: Haswell, 2013, or newer) |
| Linux, x86-64 | the release binary | x86-64-v3, and glibc 2.39 or newer (Ubuntu 24.04, Debian 13, Fedora 40) |
| Linux, ARM | the release's source, built with Rust | none: the build targets your CPU |

The engine's release workflow builds each binary for a portable CPU baseline
rather than the build machine's CPU, so one file serves every machine of that
kind. It publishes no Linux ARM binary, so there the formula builds the same
release from source, which takes Homebrew's `rust` and well under a minute of
compiling.

## Layout

| Path | Contents |
| --- | --- |
| `Formula/braveheart.rb` | The formula: a download and its sha256 for each platform, the install step, and the `brew test` checks (the version, perft 4 from the starting position, and a UCI search). |
| `.github/workflows/ci.yml` | Commit and PR title linting, and the Formula jobs: install, test, linkage and audit on each platform, then style and a load on every OS and architecture. |

## Contributing

Changes to the engine belong in the
[engine repository](https://github.com/Braveheart-Chess/braveheart); this one
only packages its releases. The repository rules are in
[CONTRIBUTING.md](CONTRIBUTING.md), and restated for coding agents in
[AGENTS.md](AGENTS.md).

## Licence

The formula and the workflows are MIT ([LICENSE](LICENSE)), and so is the
engine. The logo is not covered by either; see
[braveheart-branding](https://github.com/Braveheart-Chess/braveheart-branding#licence).
