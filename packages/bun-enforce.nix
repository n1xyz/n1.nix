# Checks that user does not use other non browser TS/JS ecosystem except bun
{ writeShellApplication, fd }:
writeShellApplication {
  name = "enforce-bun";
  runtimeInputs = [ fd ];
  text = ''
    f=$(
      fd --hidden --no-ignore \
        --exclude node_modules \
        --exclude .git \
        'package-lock\.json|yarn\.lock|pnpm-.*\.yaml'
    )
    if [ -n "$f" ]; then
      echo >&2 "error: found files from other package managers; please use bun. files:"
      echo >&2 "$f"
      exit 1
    fi
  '';
}
