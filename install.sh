#!/bin/sh
# Installs the myserv CLI: curl -fsSL https://raw.githubusercontent.com/MyServ-ge/myserv-cli/main/install.sh | sh
# Env: MYSERV_VERSION (default: the latest release), MYSERV_INSTALL_DIR (default: /usr/local/bin if writable, else ~/.local/bin).
set -eu

repo="MyServ-ge/myserv-cli"
fail() { echo "myserv install: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || fail "$1 is required"; }
need curl; need tar; need uname

case "$(uname -s)" in
  Darwin) os=darwin ;;
  Linux) os=linux ;;
  *) fail "unsupported system $(uname -s); on Windows download the .zip from https://github.com/$repo/releases" ;;
esac
case "$(uname -m)" in
  x86_64 | amd64) arch=amd64 ;;
  arm64 | aarch64) arch=arm64 ;;
  *) fail "unsupported processor $(uname -m)" ;;
esac

version="${MYSERV_VERSION:-}"
if [ -z "$version" ]; then
  # The latest release page redirects to .../tag/<version>.
  version=$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/$repo/releases/latest" | sed 's#.*/tag/##')
  [ -n "$version" ] || fail "could not find the latest version"
fi

file="myserv_${version}_${os}_${arch}.tar.gz"
base="https://github.com/$repo/releases/download/$version"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "Downloading myserv $version for $os/$arch..."
curl -fsSL "$base/$file" -o "$tmp/$file" || fail "download failed: $base/$file"
curl -fsSL "$base/checksums.txt" -o "$tmp/checksums.txt" || fail "could not download checksums.txt"

want=$(grep " \./$file\$\| $file\$" "$tmp/checksums.txt" | awk '{print $1}')
[ -n "$want" ] || fail "$file is not in checksums.txt"
if command -v sha256sum >/dev/null 2>&1; then got=$(sha256sum "$tmp/$file" | awk '{print $1}'); else got=$(shasum -a 256 "$tmp/$file" | awk '{print $1}'); fi
[ "$want" = "$got" ] || fail "checksum mismatch for $file"

tar -xzf "$tmp/$file" -C "$tmp" myserv

dir="${MYSERV_INSTALL_DIR:-}"
if [ -z "$dir" ]; then
  if [ -w /usr/local/bin ]; then dir=/usr/local/bin; else dir="$HOME/.local/bin"; fi
fi
mkdir -p "$dir"
install -m 0755 "$tmp/myserv" "$dir/myserv" 2>/dev/null || { cp "$tmp/myserv" "$dir/myserv" && chmod 0755 "$dir/myserv"; }

echo "Installed $("$dir/myserv" version) to $dir/myserv"
case ":$PATH:" in *":$dir:"*) ;; *) echo "Add $dir to your PATH to run myserv from anywhere." ;; esac
echo "Next: create an API key in the portal (MyServ Apps → API keys), then run: myserv login"
