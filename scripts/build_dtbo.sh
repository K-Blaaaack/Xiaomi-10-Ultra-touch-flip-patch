#!/bin/bash
set -e

# DTBO 构建脚本 - 使用 mkdtboimg.py
DTS_FILE="$1"
OUT="$2"

if [ $# -ne 2 ]; then 
    echo "Usage: $0 <input.dts> <output.img>"
    exit 1
fi

if [ ! -f "$DTS_FILE" ]; then
    echo "❌ Error: DTS file not found: $DTS_FILE"
    exit 1
fi

if [ ! -f "scripts/mkdtboimg.py" ]; then
    echo "❌ Error: mkdtboimg.py not found"
    exit 1
fi

# 临时目录
TMP_DIR=$(mktemp -d)
DTB_FILE="$TMP_DIR/main.dtb"
trap "rm -rf $TMP_DIR" EXIT

echo "Compiling DTS -> DTB..."
dtc -I dts -O dtb -o "$DTB_FILE" "$DTS_FILE"

if [ ! -s "$DTB_FILE" ]; then
    echo "❌ Error: DTB compilation failed"
    exit 1
fi

DTB_SIZE=$(wc -c < "$DTB_FILE")
echo "✅ DTB created: ${DTB_SIZE} bytes"

echo "Generating DTBO: $OUT ..."
# ✅ 使用 mkdtboimg.py 而不是 create 命令
python3 scripts/mkdtboimg.py create "$OUT" --page_size 4096 "$DTB_FILE"

if [ ! -f "$OUT" ]; then
    echo "❌ Error: DTBO creation failed"
    exit 1
fi

DTBO_SIZE=$(wc -c < "$OUT")
echo "✅ DTBO created: $OUT (${DTBO_SIZE} bytes)"