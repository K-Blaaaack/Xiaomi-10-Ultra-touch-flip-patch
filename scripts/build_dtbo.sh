#!/bin/bash
# build_dtbo.sh - 编译 DTS 并生成 DTBO
# Author: K-Black

set -e

# 输出文件
OUT=dtbo.img
# 页大小
PAGE_SIZE=4096

# 脚本所在目录
SCRIPT_DIR=$(dirname "$0")
# DTS 源码目录
DTBO_DIR="$SCRIPT_DIR/../dtbo"
# 临时 DTB 输出目录
TMP_DIR="$SCRIPT_DIR/dtb_tmp"
# mkdtboimg.py 脚本
MKDTBO="$SCRIPT_DIR/mkdtboimg.py"

# 检查 mkdtboimg.py 是否存在
if [ ! -f "$MKDTBO" ]; then
    echo "Error: mkdtboimg.py not found!"
    exit 1
fi

# 创建临时目录
mkdir -p "$TMP_DIR"

# 编译 DTS -> DTB
echo "Compiling DTS -> DTB..."
for dts in "$DTBO_DIR"/*.dts; do
    dtb="$TMP_DIR/$(basename "${dts%.dts}.dtb")"
    echo "  $dts -> $dtb"
    dtc -I dts -O dtb -o "$dtb" "$dts"
done

# 硬编码生成的 DTB 文件
DTB_FILES=(
    "$TMP_DIR/aosp_touch_invert_overlay.dtb"
    "$TMP_DIR/miui_touch_invert_overlay.dtb"
)

# 检查是否生成 DTB 文件
for f in "${DTB_FILES[@]}"; do
    if [ ! -f "$f" ]; then
        echo "Error: DTB file not found: $f"
        exit 1
    fi
done

# 打包 DTB -> DTBO
echo "Generating DTBO: $OUT ..."
python3 "$MKDTBO" create "$OUT" --page_size "$PAGE_SIZE" "${DTB_FILES[@]}"

echo "DTBO generated successfully: $OUT"
