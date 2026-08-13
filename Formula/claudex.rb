class Claudex < Formula
  desc "Launch Claude Code through an OpenAI-compatible model gateway"
  homepage "https://github.com/AojdevStudio/claudex"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AojdevStudio/claudex/releases/download/v0.2.1/claudex-v0.2.1-aarch64-apple-darwin.tar.xz"
      sha256 "58f7c656ce131eb7c741bf0aca37c1329bb9bc408178e5ca54ceb753f4a09c1c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AojdevStudio/claudex/releases/download/v0.2.1/claudex-v0.2.1-aarch64-unknown-linux-musl.tar.xz"
      sha256 "d205679e71697fd4671911138326537d25cdf286a2036c75f93c5ae6f8e07e4f"
    end

    on_intel do
      url "https://github.com/AojdevStudio/claudex/releases/download/v0.2.1/claudex-v0.2.1-x86_64-unknown-linux-musl.tar.xz"
      sha256 "d9797eab5713be219dedcaad0d781fe3d5287f1cf1f7a7528e79a95cbe3a0308"
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
      TOML

      ENV["CLAUDEX_CONFIG"] = config
      ENV["CLAUDEX_CLAUDE_PATH"] = fake_claude

      assert_equal "configuration valid\n", shell_output("#{bin}/claudex config validate")
      assert_match "--model\nprovider-opus\n-p\nFORMULA_OK\n",
                   shell_output("#{bin}/claudex --model opus -p FORMULA_OK")
    end
  end
end
