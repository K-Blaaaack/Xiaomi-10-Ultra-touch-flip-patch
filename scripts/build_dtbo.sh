#!/bin/bash
# build_dtbo.sh - 编译 DTS 并生成 DTBO
# Author: K-Black

set -e

SCRIPT_DIR=$(dirname "$0")
TMP_DIR="$SCRIPT_DIR/dtb_tmp"
OUT="dtbo.img"
PAGE_SIZE=4096
MKDTBO="$SCRIPT_DIR/mkdtboimg.py"

# DTS 文件列表（硬编码）
DTS_FILES=(
    "$SCRIPT_DIR/../dtbo/aosp_touch_invert_overlay.dts"
    "$SCRIPT_DIR/../dtbo/miui_touch_invert_overlay.dts"
)

# 检查 mkdtboimg.py 是否存在
if [ ! -f "$MKDTBO" ]; then
    echo "Error: mkdtboimg.py not found!"
    exit 1
fi

# 创建临时目录
mkdir -p "$TMP_DIR"

# 编译所有 DTS 文件为 DTB
echo "Compiling DTS -> DTB..."
for dts in "${DTS_FILES[@]}"; do
    dtb="$TMP_DIR/$(basename "${dts%.dts}.dtb")"
    echo "  $dts -> $dtb"
    dtc -I dts -O dtb -o "$dtb" "$dts"
done

# 打包 DTB -> DTBO（直接硬编码 DTB 路径）
python3 "$MKDTBO" create "$OUT" --page_size "$PAGE_SIZE" \
    "$TMP_DIR/aosp_touch_invert_overlay.dtb" \
    "$TMP_DIR/miui_touch_invert_overlay.dtb"

echo "DTBO generated successfully: $OUT"
