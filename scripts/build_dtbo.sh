#!/bin/bash
set -e

# 参数: $1 = 输入 DTS, $2 = 输出 DTBO
DTS_FILE="$1"
OUT="$2"
PAGE_SIZE=4096

SCRIPT_DIR=$(dirname "$0")
DTB_TMP_DIR="$SCRIPT_DIR/dtb_tmp"

mkdir -p "$DTB_TMP_DIR"

echo "Compiling DTS -> DTB..."
DTB_FILE="$DTB_TMP_DIR/$(basename "${DTS_FILE%.dts}.dtb")"
dtc -I dts -O dtb -o "$DTB_FILE" "$DTS_FILE"

echo "Generating DTBO: $OUT ..."
python3 "$SCRIPT_DIR/mkdtboimg.py" create "$OUT" --page_size "$PAGE_SIZE" "$DTB_FILE"

echo "DTBO generated successfully: $OUT"
