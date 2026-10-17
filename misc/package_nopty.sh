#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Jared Swarts
# SPDX-License-Identifier: MIT

# Packages addons/godot_xterm from a disable_pty=yes build into a zip.
# Usage: misc/package_nopty.sh <version> <output dir>
# Every library listed in REQUIRED must already be in addons/godot_xterm/lib.

set -euo pipefail

version="$1"
out_dir="$(mkdir -p "$2" && cd "$2" && pwd -P)"

cd "$(git rev-parse --show-toplevel)"

lib=addons/godot_xterm/lib
REQUIRED=(
	"$lib/libgodot-xterm.linux.template_debug.x86_64.so"
	"$lib/libgodot-xterm.linux.template_release.x86_64.so"
	"$lib/libgodot-xterm.macos.template_debug.framework/libgodot-xterm.macos.template_debug"
	"$lib/libgodot-xterm.macos.template_release.framework/libgodot-xterm.macos.template_release"
)
for f in "${REQUIRED[@]}"; do
	if [ ! -f "$f" ]; then
		echo "Missing library: $f" >&2
		exit 1
	fi
done

stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT

# git archive honours the export-ignore rules, so native/ sources stay out.
git archive HEAD addons/godot_xterm | tar -x -C "$stage"
cp -R "$lib"/. "$stage/$lib/"
rm -f "$stage/$lib/.gitignore" "$stage/addons/godot_xterm/.gitignore"
# The full notices list libuv and node-pty, which this build does not contain.
rm -f "$stage/addons/godot_xterm/THIRDPARTY_NOTICES.txt"
echo "$version" > "$stage/addons/godot_xterm/VERSION"

name="godot-xterm-$version.zip"
rm -f "$out_dir/$name"
(cd "$stage" && zip -qr -X "$out_dir/$name" addons)
if command -v sha256sum > /dev/null; then
	(cd "$out_dir" && sha256sum "$name" > "$name.sha256")
else
	(cd "$out_dir" && shasum -a 256 "$name" > "$name.sha256")
fi

echo "$out_dir/$name"
cat "$out_dir/$name.sha256"
