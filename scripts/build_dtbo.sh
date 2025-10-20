#!/bin/bash
set -e

DTS_FILE="$1"
OUT="$2"

[ $# -eq 2 ] || { echo "Usage: $0 <dts> <img>"; exit 1; }
[ -f "$DTS_FILE" ] || { echo "❌ $DTS_FILE not found"; exit 1; }

TEMP_DTB=$(mktemp).dtb
trap "rm -f $TEMP_DTB" EXIT

echo "📦 Compiling DTS -> DTB..."
dtc -I dts -O dtb -o "$TEMP_DTB" "$DTS_FILE"

DTB_SIZE=$(wc -c < "$TEMP_DTB")
echo "✅ DTB: ${DTB_SIZE} bytes"

echo "🔨 Creating DTBO..."
python3 scripts/mkdtboimg.py create "$OUT" --page_size 4096 "$TEMP_DTB"

IMG_SIZE=$(wc -c < "$OUT")
echo "✅ DTBO: $OUT (${IMG_SIZE} bytes)"