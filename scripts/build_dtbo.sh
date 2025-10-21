#!/bin/bash
set -e

DTS_FILE="$1"
OUT="$2"

if [ $# -ne 2 ]; then 
    echo "Usage: $0 <input.dts> <output.img>"
    exit 1
fi

if [ ! -f "$DTS_FILE" ]; then
    echo "❌ DTS file not found: $DTS_FILE"
    exit 1
fi

if [ ! -f "scripts/mkdtboimg.py" ]; then
    echo "❌ mkdtboimg.py not found!"
    exit 1
fi

TEMP_DTB=$(mktemp --suffix=.dtb)
trap "rm -f '$TEMP_DTB'" EXIT

echo "📦 Compiling DTS -> DTB..."
dtc -I dts -O dtb -o "$TEMP_DTB" "$DTS_FILE"

if [ ! -s "$TEMP_DTB" ]; then
    echo "❌ DTB compilation failed"
    exit 1
fi

DTB_SIZE=$(wc -c < "$TEMP_DTB")
echo "✅ DTB: ${DTB_SIZE} bytes"

echo "🔨 Creating DTBO..."
python3 scripts/mkdtboimg.py create "$OUT" "$TEMP_DTB"  # 默认 page_size=2048

if [ ! -f "$OUT" ]; then
    echo "❌ DTBO creation failed"
    exit 1
fi

IMG_SIZE=$(wc -c < "$OUT")
echo "✅ DTBO: $OUT (${IMG_SIZE} bytes)"
file "$OUT"