# Ogrodje Reporting

This is experimental project built for the collection of Ogrodje Podcast metrics.

## Usage

First make sure that you have the [anchor-collector] and [youtube-collector] installed.

Then you can use [`PowerShell`][powershell] directly or view [`Nix Shell`][nix-shell]

```bash
pwsh build-report.ps1
# open report.html
```

```bash
nix-shell -p powershell --run "pwsh build-report.ps1"
```

# Author

[Oto Brglez](https://github.com/otobrglez)

[anchor-collector]: https://github.com/otobrglez/anchor-collector
[youtube-collector]: https://github.com/otobrglez/youtube-collector
[powershell]: https://learn.microsoft.com/en-us/powershell/
[nix-shell]: https://nixos.org/manual/nix/stable/command-ref/nix-shell.html
