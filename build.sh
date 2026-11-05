#!/usr/bin/env bash
# Builds the Cube Warper v1.15 server pack from public CurseForge files.
set -euo pipefail

PROJECT=1711334
SERVER_V114_FILE=9276735
SERVER_V114_SHA1=6143d8b5de1f054b6679752b863de00d68cf4f55
CLIENT_V115_FILE=9446645
EXPECTED_JARS=160
OUTPUT="Cube-Warper-server-v1.15.zip"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK="$ROOT/work"
SERVER="$WORK/server"
CLIENT="$WORK/client"

download() { # project file output
  curl -fsSL --retry 5 --retry-delay 5 -o "$3" "https://www.curseforge.com/api/v1/mods/$1/files/$2/download"
}

rm -rf "$WORK" "$ROOT/dist"
mkdir -p "$SERVER" "$CLIENT" "$ROOT/dist"

echo "==> Downloading public v1.14 server pack"
download "$PROJECT" "$SERVER_V114_FILE" "$WORK/server-v1.14.zip"
echo "$SERVER_V114_SHA1  $WORK/server-v1.14.zip" | sha1sum --quiet -c
python3 -m zipfile -e "$WORK/server-v1.14.zip" "$SERVER"
rm "$WORK/server-v1.14.zip"

echo "==> Downloading public v1.15 client pack (for changed configs and scripts)"
download "$PROJECT" "$CLIENT_V115_FILE" "$WORK/client-v1.15.zip"
python3 -m zipfile -e "$WORK/client-v1.15.zip" "$CLIENT"
rm "$WORK/client-v1.15.zip"

echo "==> Removing old mods"
while IFS= read -r mod; do
  rm "$SERVER/mods/$mod"
done < "$ROOT/remove-mods.txt"

echo "==> Downloading new mods"
while read -r project file name; do
  echo "    $name"
  download "$project" "$file" "$SERVER/mods/$name"
done < "$ROOT/new-mods.txt"

echo "==> Copying changed files from the v1.15 client pack"
while IFS= read -r path; do
  mkdir -p "$(dirname "$SERVER/$path")"
  cp "$CLIENT/overrides/$path" "$SERVER/$path"
done < "$ROOT/override-files.txt"

echo "==> Verifying"
(cd "$SERVER" && sha1sum --quiet -c "$ROOT/checksums.sha1")
jars=$(find "$SERVER/mods" -maxdepth 1 -name '*.jar' | wc -l)
[ "$jars" -eq "$EXPECTED_JARS" ] || { echo "Expected $EXPECTED_JARS jars, found $jars" >&2; exit 1; }

echo "==> Creating $OUTPUT"
chmod +x "$SERVER/run.sh"
(cd "$SERVER" && zip -qry "$ROOT/dist/$OUTPUT" .)
ls -l "$ROOT/dist"
