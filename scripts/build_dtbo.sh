#!/bin/bash
# build_dtbo.sh - 编译 DTS 并生成 DTBO
# Author: K-Black

set -e

SCRIPT_DIR=$(dirname "$0")
DTBO_DIR="$SCRIPT_DIR/../dtbo"
TMP_DIR="$SCRIPT_DIR/dtb_tmp"
OUT="dtbo.img"
PAGE_SIZE=4096
MKDTBO="$SCRIPT_DIR/mkdtboimg.py"

# 检查 mkdtboimg.py 是否存在
if [ ! -f "$MKDTBO" ]; then
    echo "Error: mkdtboimg.py not found!"
    exit 1
fi

# 创建临时目录
mkdir -p "$TMP_DIR"

# 编译所有 DTS 文件为 DTB
echo "Compiling DTS -> DTB..."
for dts in "$DTBO_DIR"/*.dts; do
    dtb="$TMP_DIR/$(basename "${dts%.dts}.dtb")"
    echo "  $dts -> $dtb"
    dtc -I dts -O dtb -o "$dtb" "$dts"
done

# 把 DTB 文件放入数组
DTB_FILES=("$TMP_DIR"/*.dtb)

# 检查是否有 DTB 文件
if [ ${#DTB_FILES[@]} -eq 0 ]; then
    echo "Error: No DTB files generated!"
    exit 1
fi

# 打包 DTB -> DTBO
echo "Generating DTBO: $OUT ..."
python3 "$MKDTBO" create "$OUT" --page_size "$PAGE_SIZE" "${DTB_FILES[@]}"

echo "DTBO generated successfully: $OUT"
