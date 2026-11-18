# The Bump workflow (.github/workflows/bump.yml) keeps the version in the four
# URLs, and their sha256 values, in step with the engine's latest release.
class Braveheart < Formula
  desc "UCI chess engine with an NNUE trained on its own self-play"
  homepage "https://github.com/Braveheart-Chess/braveheart"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  # The engine's own release binaries: built by its release workflow for a
  # portable CPU baseline (apple-m1 on Apple silicon, x86-64-v3 on Intel), with
  # the NNUE net embedded, so there is nothing else to download.
  on_macos do
    on_arm do
      url "https://github.com/Braveheart-Chess/braveheart/releases/download/v0.54.0/braveheart-v0.54.0-aarch64-apple-darwin.tar.gz"
      sha256 "c18ac6e3a514b3ec493524e5a65df7a659da02e69285f61783feb72df7259360"
    end
    on_intel do
      url "https://github.com/Braveheart-Chess/braveheart/releases/download/v0.54.0/braveheart-v0.54.0-x86_64-apple-darwin.tar.gz"
      sha256 "f80eda1e3efdc0807ceb72569dc8964c6439e28aa3852a0f32d83367684aff54"
    end
  end

  on_linux do
    # The engine publishes no Linux ARM binary, so there the formula builds
    # the same release from source, for the host CPU.
    on_arm do
      url "https://github.com/Braveheart-Chess/braveheart/archive/refs/tags/v0.54.0.tar.gz"
      sha256 "077a0d4933914c0e6cf30f406b9d6c5337ff38f4d050ea30982c3c6a8f6fb384"

      depends_on "rust" => :build
    end
    on_intel do
      url "https://github.com/Braveheart-Chess/braveheart/releases/download/v0.54.0/braveheart-v0.54.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "473abc98bae7ea0faa5aec1760dc169a3bf40b26b5fcbe3f2be2ec0a43c4664f"
    end
  end

  def install
    if (buildpath/"Cargo.toml").exist?
      system "cargo", "install", *std_cargo_args
    else
      bin.install "braveheart"
    end
  end

  test do
    assert_match "braveheart #{version}", shell_output("#{bin}/braveheart --version")

    # Move generation: perft 4 from the starting position is 197,281 leaves.
    assert_match(/Nodes searched\s*:\s*197281$/, shell_output("#{bin}/braveheart perft --depth 4"))

    # UCI: the handshake a GUI sends, then a short search that ends in a move.
    output = pipe_output(bin/"braveheart", "uci\nisready\nposition startpos\ngo depth 8\n", 0)
    assert_match "uciok", output
    assert_match "readyok", output
    assert_match(/^bestmove [a-h][1-8][a-h][1-8]/, output)
  end
end
