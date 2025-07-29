{
  writeShellApplication,
  curl,
  jq,
  # Process compose instance
  PC_PORT_NUM ? 32017,
  # Process to wait for
  TARGET_PROCESS_NAME ? "postgres",
}:

writeShellApplication rec {
  name = "external-ready";
  runtimeInputs = [
    curl
    jq
  ];
  derivationArgs = {
    PC_PORT_NUM = builtins.toString PC_PORT_NUM;
    inherit TARGET_PROCESS_NAME;
  };
  text = ''
    export PC_PORT_NUM=${derivationArgs.PC_PORT_NUM}
    export PC_READ_ONLY=true
    set +o errexit
    while [[ $(curl http://localhost:${derivationArgs.PC_PORT_NUM}/process/${derivationArgs.TARGET_PROCESS_NAME} | jq .is_ready -r) != "Ready" ]]; do
        echo "⌛ waiting for externals Ready"
        sleep 5
    done
  '';
}
