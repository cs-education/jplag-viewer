#!/usr/bin/env bash
# Extract the JPlag report viewer bundled in a JPlag jar and patch it to be
# served from a subpath (GitHub Pages project site) instead of a domain root.
#
#   ./build.sh <jplag-jar> <base-path>
#   ./build.sh ../jplag-6.3.0-jar-with-dependencies.jar /jplag-viewer/
#
# Use base-path "/" when serving from a domain root (custom domain).
# Output goes to ./docs (point GitHub Pages at main:/docs).
set -euo pipefail

jar=${1:?usage: build.sh <jplag-jar> <base-path>}
base=${2:?usage: build.sh <jplag-jar> <base-path>}
[[ $base == /*/ || $base == / ]] || { echo "base-path must start and end with /" >&2; exit 1; }

out=docs
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

unzip -q "$jar" 'report-viewer/*' -d "$tmp"
rm -rf "$out"
mv "$tmp/report-viewer" "$out"

# replace <file> <literal-from> <literal-to> <expected-count>
# Fails loudly if a new JPlag release changes the bundle layout.
replace() {
  python3 - "$@" <<'PY'
import sys
path, old, new, want = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])
s = open(path).read()
n = s.count(old)
if n != want:
    sys.exit(f"{path}: expected {want} occurrence(s) of {old!r}, found {n}")
open(path, "w").write(s.replace(old, new))
PY
}

js=$(echo "$out"/assets/index-*.js)
[[ -f $js ]] || { echo "expected exactly one assets/index-*.js" >&2; exit 1; }

replace "$out/index.html" '"/assets/' "\"${base}assets/" 2
replace "$out/index.html" '"/favicon.ico"' "\"${base}favicon.ico\"" 1
replace "$js" '"/assets/' "\"${base}assets/" 2
replace "$js" 'history:Uw("/")' "history:Uw(\"${base}\")" 1
replace "$js" '${window.location.origin}/' "\${window.location.origin}${base}" 2

# Deep links (e.g. a reload on /overview) land on 404.html; send them to the
# upload page. The loaded report lives only in memory, so nothing is lost.
cat > "$out/404.html" <<HTML
<!doctype html>
<meta charset="utf-8">
<script>location.replace("${base}")</script>
HTML
touch "$out/.nojekyll"

version=$(unzip -p "$jar" META-INF/MANIFEST.MF | sed -n 's/^Implementation-Version: *//p' | tr -d '\r')
echo "${version:-unknown}" > "$out/JPLAG_VERSION"
echo "Built JPlag ${version:-?} viewer into $out/ (base $base)"
