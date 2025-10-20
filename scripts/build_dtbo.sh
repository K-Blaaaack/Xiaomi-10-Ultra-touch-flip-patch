#!/bin/bash
set -e

OUT=out
mkdir -p ${OUT}

DTC=dtc
MKDTOB=mkdtboimg

# 构建 MIUI
echo "编译 MIUI DTBO..."
${DTC} -I dts -O dtb -o ${OUT}/overlay_miui.dtb dtbo/miui_touch_invert_overlay.dts
${MKDTOB} --page_size 4096 --output ${OUT}/dtbo_fixed_miui.img ${OUT}/overlay_miui.dtb

# 构建 AOSP
echo "编译 AOSP DTBO..."
${DTC} -I dts -O dtb -o ${OUT}/overlay_aosp.dtb dtbo/aosp_touch_invert_overlay.dts
${MKDTOB} --page_size 4096 --output ${OUT}/dtbo_fixed_aosp.img ${OUT}/overlay_aosp.dtb

echo "✅ 已生成 dtbo_fixed_miui.img 和 dtbo_fixed_aosp.img"
