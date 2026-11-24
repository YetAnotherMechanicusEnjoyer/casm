# casm

<p align="center"> 
  <img alt="AUR Version" src="https://img.shields.io/aur/version/casm-cli?style=for-the-badge&logo=archlinux&logoColor=white&label=casm-cli&labelColor=1793D1&link=https%3A%2F%2Faur.archlinux.org%2Fpackages%2Fcasm-cli">
  <img alt="Nix Flake" src="https://img.shields.io/badge/casm-flake-5277C3?style=for-the-badge&logo=nixos&logoColor=white&labelColor=5277C3&link=https%3A%2F%2Fgithub.com%2FYetAnotherMechanicusEnjoyer%2Fcasm%2Fblob%2Fea7491a9dec1b0f5c0ec1b6a9a9cdc92171c2f87%2Fflake.nix">
  <img alt="DEB Package" src="https://img.shields.io/badge/casm-deb-A81D33?style=for-the-badge&logo=debian&logoColor=white&labelColor=A81D33&link=https%3A%2F%2Fgithub.com%2FYetAnotherMechanicusEnjoyer%2Fcasm%2Ftree%2Fgh-pages%2Fdebian">
  <img alt="RPM Package" src="https://img.shields.io/badge/casm-rpm-51A2DA?style=for-the-badge&logo=fedora&logoColor=white&labelColor=51A2DA&link=https%3A%2F%2Fgithub.com%2FYetAnotherMechanicusEnjoyer%2Fcasm%2Ftree%2Fgh-pages%2Frpm">


  <br>

  <img alt="AUR Publisher" src="https://img.shields.io/github/actions/workflow/status/YetAnotherMechanicusEnjoyer/casm/aur.yml?style=for-the-badge&logo=github-actions&logoColor=white&label=AUR%20Publisher&labelColor=010409&link=https%3A%2F%2Fgithub.com%2FYetAnotherMechanicusEnjoyer%2Fcasm%2Factions%2Fworkflows%2Faur.yml">
  <img alt="Nix Publisher" src="https://img.shields.io/github/actions/workflow/status/YetAnotherMechanicusEnjoyer/casm/nix.yml?style=for-the-badge&logo=github-actions&logoColor=white&label=Nix%20Publisher&labelColor=010409&link=https%3A%2F%2Fgithub.com%2FYetAnotherMechanicusEnjoyer%2Fcasm%2Factions%2Fworkflows%2Fnix.yml">
  <img alt="DEB Publisher" src="https://img.shields.io/github/actions/workflow/status/YetAnotherMechanicusEnjoyer/casm/deb.yml?style=for-the-badge&logo=github-actions&logoColor=white&label=DEB%20Publisher&labelColor=010409&link=https%3A%2F%2Fgithub.com%2FYetAnotherMechanicusEnjoyer%2Fcasm%2Factions%2Fworkflows%2Fdeb.yml">
  <img alt="RPM Publisher" src="https://img.shields.io/github/actions/workflow/status/YetAnotherMechanicusEnjoyer/casm/rpm.yml?style=for-the-badge&logo=github-actions&logoColor=white&label=RPM%20Publisher&labelColor=010409&link=https%3A%2F%2Fgithub.com%2FYetAnotherMechanicusEnjoyer%2Fcasm%2Factions%2Fworkflows%2Frpm.yml">
  
  <br>

  <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/YetAnotherMechanicusEnjoyer/casm?display_timestamp=committer&style=for-the-badge&logo=github&labelColor=010409">
  <img alt="GitHub License" src="https://img.shields.io/github/license/YetAnotherMechanicusEnjoyer/casm?style=for-the-badge&logo=gplv3&logoColor=white&labelColor=010409&color=BD0000&link=https%3A%2F%2Fgithub.com%2FYetAnotherMechanicusEnjoyer%2Fwayra%2Fblob%2F97f424c116b690a2703a5e83d5a9bddcaeec8545%2FLICENSE">
</p>

A small build system for NASM projects

## Usage
```bash
casm - a build tool for NASM projects

USAGE:
  casm init [--force] [--file PATH]
  casm [build] [options] [source.asm ...]
  casm run [options] [-- program-arguments ...]
  casm clean

COMMANDS:
  init                  Create a build.casm for the current project.
  build                 Assemble and link (default).
  run                   Build, then run the executable.
  clean, clear          Remove the build directory.
  help                  Show this help.

OPTIONS:
  -f, --file PATH       Build file (default: build.casm).
  -o, --output PATH     Override the executable path.
      --build-dir PATH  Override the build directory.
      --debug           Include DWARF debug information.
      --no-debug        Disable debug information.
      --force           Rebuild everything (or overwrite on init).
      --valgrind        Run under Valgrind (run only).
      --strace          Run under strace (run only).
  -v, --verbose         Show commands and additional build information.
  -q, --quiet           Hide casm logs; program output is preserved.
      --no-color        Disable colored output.
  -h, --help            Show this help.

SOURCE CONFIGURATION (build.casm):
  [sources]
  root = "src"                 Discover every .asm file recursively.
  root = "libasm"              Additional source directory.
  exclude = "src/tests/**"     Exclude a subtree or matching files.
  include = "include"          NASM include directory.
  asm = "generated/start.asm"  Optional individual source file.

EXAMPLES:
  casm init
  casm build --debug
  casm run -- arg1 "hello world"
  casm run --quiet | grep SUCCESS
  casm clean
```

## Installation

### Arch Linux ([AUR](https://aur.archlinux.org/packages/casm-cli))

Requires any AUR Helper like [YaY](https://github.com/Jguer/yay)

e.g.:
```bash
yay -S casm-cli
```

### Nix / NixOS

If you use Nix with flakes enabled, you can run or install wayra instantly in a reproducible way:

**Run directly without installation:**
```bash
nix run github:YetAnotherMechanicusEnjoyer/casm
```

**Install via a Flake:**
```nix
inputs.casm.url = "github:YetAnotherMechanicusEnjoyer/casm";
```

```nix
{
  imports = [
    inputs.casm.nixosModules.default
  ];

  programs.casm.enable = true;
}
```

*(Note: I am purely speculating, I still need confirmation from a Nix user.)*

### DEB / RPM
> Setup into `/usr`

Registers the casm repository (`gh-pages` branch) in `dnf` or `apt`

```bash
wget -qO- https://raw.githubusercontent.com/YetAnotherMechanicusEnjoyer/casm/main/setup.sh | bash -s
```

| Argument | Effect |
| -------- | ------ |
| `--install` | Also installs `casm` |
| `--no-sudo` | Runs without `sudo` (already root) |
| `-h`, `--help` | Displays the usage |

### Debian / Ubuntu (APT)

e.g.:
```bash
sudo apt install casm
```

### Fedora / RHEL (DNF)

e.g.:
```bash
sudo dnf install casm
```

### Manual install
> Setup into `/usr/bin`

Requires `nasm` and `binutils`

#### Clone the repository & Install
```bash
git clone https://github.com/YetAnotherMechanicusEnjoyer/casm.git
cd casm
sudo mv ./casm /usr/bin/casm
```
