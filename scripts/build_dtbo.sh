#!/bin/bash
set -e

# 输入 DTS 文件, 输出 DTBO 文件
DTS_FILE="$1"
OUT="$2"

# 临时目录
TMP_DIR="./dtb_tmp"
mkdir -p "$TMP_DIR"

# 编译 DTS -> DTB
DTB_FILE="$TMP_DIR/$(basename "${DTS_FILE%.dts}.dtb")"
echo "Compiling DTS -> DTB..."
dtc -I dts -O dtb -o "$DTB_FILE" "$DTS_FILE"

# 生成 DTBO，硬编码 page_size 为 4096
echo "Generating DTBO: $OUT ..."
python3 ./scripts/mkdtboimg.py create "$OUT" --page_size 4096 "$DTB_FILE"

echo "DTBO generated successfully: $OUT"
