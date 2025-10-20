#!/bin/bash
set -e

# Python mkdtboimg 路径
MKDTBOIMG="mkdtboimg.py"

# 输出目录
OUTDIR="./out"
mkdir -p $OUTDIR

# 编译 MIUI 版本
dtc -I dts -O dtb -o $OUTDIR/miui.dtb dtbo/miui_touch_invert_overlay.dts
python3 $MKDTBOIMG --page_size 4096 --output $OUTDIR/dtbo_miui_invert.img $OUTDIR/miui.dtb

# 编译 AOSP 版本（如果有）
if [ -f dtbo/aosp_touch_invert_overlay.dts ]; then
    dtc -I dts -O dtb -o $OUTDIR/aosp.dtb dtbo/aosp_touch_invert_overlay.dts
    python3 $MKDTBOIMG --page_size 4096 --output $OUTDIR/dtbo_aosp_invert.img $OUTDIR/aosp.dtb
fi

echo "✅ DTBO 编译完成，文件位于 $OUTDIR"
