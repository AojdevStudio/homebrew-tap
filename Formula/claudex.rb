class Claudex < Formula
  desc "Launch Claude Code through an OpenAI-compatible model gateway"
  homepage "https://github.com/AojdevStudio/claudex"
  url "https://github.com/AojdevStudio/claudex/releases/download/v0.1.0/claudex-v0.1.0-aarch64-apple-darwin.tar.xz"
  sha256 "37ae3c4680f83416f678a5a3b55bdc4ee79839acf81bfe5cfe32a4e4225246cc"
  license "MIT"

  depends_on arch: :arm64
  depends_on :macos

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
