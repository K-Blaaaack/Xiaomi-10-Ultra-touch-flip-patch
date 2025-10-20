#!/bin/bash
# build_dtbo.sh - 编译 DTS 并生成 DTBO
# Author: K-Black

set -e

# 输出文件
OUT=dtbo.img
# 页大小，可根据设备需求修改
PAGE_SIZE=4096
# DTS 源码目录
DTS_DIR="../dtbo"
# 临时 DTB 输出目录
DTB_TMP_DIR="./dtb_tmp"

# 检查 mkdtboimg.py 是否存在
if [ ! -f "../mkdtboimg.py" ]; then
    echo "Error: mkdtboimg.py not found!"
    exit 1
fi

# 创建临时目录
mkdir -p "$DTB_TMP_DIR"

# 编译所有 DTS 文件为 DTB
echo "Compiling DTS -> DTB..."
for dts in "$DTS_DIR"/*.dts; do
    dtb="$DTB_TMP_DIR/$(basename "${dts%.dts}.dtb")"
    echo "  $dts -> $dtb"
    dtc -I dts -O dtb -o "$dtb" "$dts"
done

# 找到生成的 DTB 文件
DTB_FILES=$(find "$DTB_TMP_DIR" -maxdepth 1 -type f -name "*.dtb" | sort)
if [ -z "$DTB_FILES" ]; then
    echo "Error: No DTB files generated!"
    exit 1
fi

# 打包 DTB -> DTBO
echo "Generating DTBO: $OUT ..."
python3 ../mkdtboimg.py create "$OUT" --page_size $PAGE_SIZE $DTB_FILES

echo "DTBO generated successfully: $OUT"
