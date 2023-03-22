with (import <nixpkgs> {});

mkShell {
  buildInputs = [
    powershell
  ];

  shellHook = ''
    # pwsh
  '';
}
