            build-static-release =
              {
                cargo-zigbuild,
                rust-toolchain,
                mimalloc,
                git,
                writeShellApplication,
                extra-runtimeInputs ? [ ],
              }:

              writeShellApplication {
                name = "build-static-release";
                runtimeInputs = [
                  cargo-zigbuild
                  mimalloc
                  rust-toolchain
                  git
                ] ++ extra-runtimeInputs;

                text = ''
                  if [ -n "$(git status --porcelain)" ]; then
                    echo >&2 'dirty tree, refusing to build; stash or commit your changes'
                    exit 1
                  fi
                  set -x
                  # zig 0.14.0 causes ProcessFdQuotaExceeded on macos, so raise the limit.
                  # this fails if some parent process has already called `ulimit -n`, so
                  # you may need to open a new shell in that case.
                  ${if pkgs.stdenv.isDarwin then "ulimit -n 8192" else ""} #
                  # mimalloc uses __DATE__, __TIME__ macros
                  export CFLAGS="-Wno-error=date-time"
                  export RUSTFLAGS="-C target-feature=+crt-static"
                  cargo zigbuild \
                      --target=x86_64-unknown-linux-musl \
                      --release \
                      "$@"
                '';
              };  



        external-ready = pkgs.writeShellApplication rec {
          name = "external-ready";
          runtimeInputs = [
            pkgs.curl
            pkgs.jq
          ];
          derivationArgs = {
            PC_PORT_NUM = "32017";
          };
          text = ''
            export PC_PORT_NUM=${derivationArgs.PC_PORT_NUM}
            export PC_READ_ONLY=true
            set +o errexit
            while [[ $(curl http://localhost:${derivationArgs.PC_PORT_NUM}/process/postgres | jq .is_ready -r) != "Ready" ]]; do
                echo "⌛ waiting for externals Ready"
                sleep 5
            done
          '';
        };