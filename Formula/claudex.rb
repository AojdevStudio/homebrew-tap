class Claudex < Formula
  desc "Launch Claude Code through an OpenAI-compatible model gateway"
  homepage "https://github.com/AojdevStudio/claudex"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AojdevStudio/claudex/releases/download/v0.3.0/claudex-v0.3.0-aarch64-apple-darwin.tar.xz"
      sha256 "305be5d1ae61d88269f84c0b45d6e81addbc51b66ea0d3c4768e11528be30beb"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AojdevStudio/claudex/releases/download/v0.3.0/claudex-v0.3.0-aarch64-unknown-linux-musl.tar.xz"
      sha256 "20f955732ea109593063e1882b07388cbb1061c5b57ed6c67829864f66b5165d"
    end

    on_intel do
      url "https://github.com/AojdevStudio/claudex/releases/download/v0.3.0/claudex-v0.3.0-x86_64-unknown-linux-musl.tar.xz"
      sha256 "fc9c4bcb7148e53b193c0985b0c701ded1412fc3a446e506370e7d0b370a1513"
    end
  end

  def install
    bin.install "claudex"
    generate_completions_from_executable(bin/"claudex", "completions", shells: [:zsh])
  end

  test do
    assert_match "claudex #{version}", shell_output("#{bin}/claudex --version")
    assert_match "--proxy-model", shell_output("#{bin}/claudex --help")

    if OS.mac?
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

        [context_windows]
        "provider-fable" = 200000
        "provider-opus" = 200000
        "provider-sonnet" = 200000
        "provider-haiku" = 200000
      TOML

      ENV["CLAUDEX_CONFIG"] = config
      ENV["CLAUDEX_CLAUDE_PATH"] = fake_claude

      assert_equal "configuration valid\n", shell_output("#{bin}/claudex config validate")
      assert_match "--model\nprovider-opus\n-p\nFORMULA_OK\n",
                   shell_output("#{bin}/claudex --model opus -p FORMULA_OK")
    end
  end
end
