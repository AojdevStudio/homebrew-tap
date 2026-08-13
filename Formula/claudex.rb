class Claudex < Formula
  desc "Launch Claude Code through an OpenAI-compatible model gateway"
  homepage "https://github.com/AojdevStudio/claudex"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AojdevStudio/claudex/releases/download/v0.2.0/claudex-v0.2.0-aarch64-apple-darwin.tar.xz"
      sha256 "46deb59d1ff49467273667a7677105ba13b15517ae01b512787ddb58477b2db0"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AojdevStudio/claudex/releases/download/v0.2.0/claudex-v0.2.0-aarch64-unknown-linux-musl.tar.xz"
      sha256 "2f0d05cdc2729b4cc61ccb0022c41d8bd3faf31d6cdb9377407ea822752c25d5"
    end

    on_intel do
      url "https://github.com/AojdevStudio/claudex/releases/download/v0.2.0/claudex-v0.2.0-x86_64-unknown-linux-musl.tar.xz"
      sha256 "ab485e40100e32990ff6fada6e824c4a346bb7782d6fdb0df11a1c18dd5f82df"
    end
  end

  def install
    bin.install "claudex"
    generate_completions_from_executable(bin/"claudex", "completions", shells: [:zsh])
  end

  test do
    key = testpath/"api-key"
    key.write "formula-fixture-key\n"
    key.chmod 0600

    fake_claude = testpath/"claude"
    fake_claude.write <<~SH
      #!/bin/sh
      printf '%s\\n' "$@"
    SH
    fake_claude.chmod 0700

    config = testpath/"config.toml"
    config.write <<~TOML
      [proxy]
      base_url = "http://127.0.0.1:18317"
      api_key_file = "#{key}"

      [defaults]
      model = "fable"

      [models]
      fable = "provider-fable"
      opus = "provider-opus"
      sonnet = "provider-sonnet"
      haiku = "provider-haiku"
    TOML

    ENV["CLAUDEX_CONFIG"] = config
    ENV["CLAUDEX_CLAUDE_PATH"] = fake_claude

    assert_equal "configuration valid\n", shell_output("#{bin}/claudex config validate")
    assert_match "claudex #{version}", shell_output("#{bin}/claudex --version")
    assert_match "--model\nprovider-opus\n-p\nFORMULA_OK\n",
                 shell_output("#{bin}/claudex --model opus -p FORMULA_OK")
  end
end
