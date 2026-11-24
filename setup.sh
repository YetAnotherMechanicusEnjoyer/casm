#!/bin/bash
# Package repository setup of casm: registers the gh-pages repository (RPM / DEB, unsigned) in the system
# package manager (--install also installs the package).
set -euo pipefail

BASE_URL="${CASM_REPO_URL:-https://yetanothermechanicusenjoyer.github.io/casm}" # gh-pages of a fork: CASM_REPO_URL=https://<owner>.github.io/casm
PACKAGE="casm"
SUDO="sudo"
INSTALL=false

# =========================
# Parse arguments
# =========================
usage() {
    echo "Usage: $0 [--no-sudo] [--install]"
    echo "  --no-sudo      Run without sudo (requires the script to be run as root already)"
    echo "  --install      Also install the package (by default only the mirror is setup)"
    exit 1
}

for arg in "$@"; do
    case "$arg" in
        --no-sudo)
            SUDO=""
            ;;
        --install)
            INSTALL=true
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Error: unknown argument '$arg'" >&2
            usage
            ;;
    esac
done

if [[ -z "$SUDO" ]] && [[ "$(id -u)" -ne 0 ]]; then
    echo "Error: --no-sudo requires the script to be run as root." >&2
    exit 1
fi

# =========================
# Requirements
# =========================
require() {
    for cmd in "$@"; do
        if ! command -v "$cmd" > /dev/null 2>&1; then
            echo "Error: '$cmd' is required but not installed." >&2
            exit 1
        fi
    done
}

# Download to stdout with curl or wget (wget only on a default Debian / Ubuntu)
if command -v curl > /dev/null 2>&1; then
    fetch() { curl -fsSL "$1"; }
elif command -v wget > /dev/null 2>&1; then
    fetch() { wget -qO- "$1"; }
else
    echo "Error: 'curl' or 'wget' is required but neither is installed." >&2
    exit 1
fi

# Install a downloaded file as root (nothing written if the download fails)
fetch_to() {
    local tmp
    tmp="$(mktemp)"
    if ! fetch "$1" > "$tmp"; then
        rm -f "$tmp"
        echo "Error: cannot download $1" >&2
        exit 1
    fi
    $SUDO install -D -m 0644 "$tmp" "$2"
    rm -f "$tmp"
}

# =========================
# Find the os
# =========================
if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    OS_ID="${ID:-unknown}"
    OS_ID_LIKE="${ID_LIKE:-}"
else
    echo "Error: /etc/os-release not found, cannot detect OS." >&2
    exit 1
fi

is_rpm_based() {
    [[ "$OS_ID" =~ ^(fedora|rhel|centos|rocky|almalinux)$ ]] || [[ "$OS_ID_LIKE" =~ (fedora|rhel) ]]
}

is_deb_based() {
    [[ "$OS_ID" =~ ^(debian|ubuntu)$ ]] || [[ "$OS_ID_LIKE" =~ (debian|ubuntu) ]]
}

# =========================
# RPM
# =========================
install_rpm_repo() {
    echo "Detected RPM-based system (ID=$OS_ID). Setting up casm repo..."

    # noarch packages: one repository for every release (see: .github/workflows/rpm.yml)
    if ! fetch "$BASE_URL/rpm/repodata/repomd.xml" > /dev/null; then
        echo "Warning: no packages published on $BASE_URL/rpm, the installation will probably fail." >&2
    fi

    fetch_to "$BASE_URL/casm.repo" /etc/yum.repos.d/casm.repo

    echo "casm repo installed."
}

install_rpm_package() {
    local pm="dnf"
    command -v dnf > /dev/null 2>&1 || pm="yum"

    echo "Installing $PACKAGE..."
    $SUDO "$pm" install -y "$PACKAGE"
}

# =========================
# DEB
# =========================
install_deb_repo() {
    echo "Detected DEB-based system (ID=$OS_ID). Setting up casm repo..."
    require dpkg

    ARCH="$(dpkg --print-architecture)"

    # Unsigned repository: trusted without GPG check (see: .github/workflows/deb.yml)
    echo "deb [arch=${ARCH} trusted=yes] ${BASE_URL}/debian stable main" \
        | $SUDO tee /etc/apt/sources.list.d/casm.list > /dev/null

    $SUDO apt-get update

    echo "casm repo installed."
}

install_deb_package() {
    echo "Installing $PACKAGE..."
    $SUDO apt-get install -y "$PACKAGE"
}

# =========================
# Dispatch
# =========================
if is_rpm_based; then
    install_rpm_repo
    if $INSTALL; then install_rpm_package; fi
elif is_deb_based; then
    install_deb_repo
    if $INSTALL; then install_deb_package; fi
else
    echo "Error: unsupported distribution (ID=$OS_ID, ID_LIKE=$OS_ID_LIKE), use the AUR or Nix package." >&2
    exit 1
fi
