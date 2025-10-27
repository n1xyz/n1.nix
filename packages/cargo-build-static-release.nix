# Builds commited binary executable cargo package release with static linking using musl and mimaloc via zig to allow cross compilation.
# `$@` all user provided parameters to cargo zigbuild
{
  cargo-zigbuild,
  rustc,
  git,
  writeShellApplication,
  # for example, to use `protoc` or `mimalloc` (it is runtime input because is needed when script runs to build)
  extra-runtimeInputs ? [ ],
  # flake or other attrset with `rev` attribute which is git commit hash string
  name ? "cargo-build-static-release",
  # must have `target`, defaults to `x86_64-unknown-linux-musl`
  target ? "x86_64-unknown-linux-musl",
  # flake for hermetic build
  self ? null,
}:

writeShellApplication {
  inherit name;
  runtimeInputs = [
    cargo-zigbuild
    rustc
    git
  ] ++ extra-runtimeInputs;
  text = ''
    ${
      if self == null then
        ''
          if [ -n "''$(git status --porcelain)" ]; then
            echo >&2 'dirty tree, refusing to build; stash or commit your changes'
            exit 1
          fi
        ''
      else
        ''
          echo "Git Commit: ${self.rev}"
        ''
    }

    set -x
    # zig 0.14.0 causes ProcessFdQuotaExceeded, so raise the limit.
    # this fails if some parent process has already called `ulimit -n`, so
    # you may need to open a new shell in that case.
    ${if self == null then "ulimit -n 8192" else ""}

    # `zig cc` sets `-Werror=date-time` which breaks some dependencies. not needed in this case
    # as this tool is not meant for reproducibility
    export CFLAGS="-Wno-error=date-time"
    export RUSTFLAGS="-C target-feature=+crt-static"
    cargo zigbuild \
        --target=${target} \
        --release \
        "$@"
  '';
}
