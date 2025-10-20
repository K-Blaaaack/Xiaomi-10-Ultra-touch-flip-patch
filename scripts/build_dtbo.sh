#!/bin/bash
set -e

DTS_FILE="$1"
OUT="$2"

echo "Building DTBO: $DTS_FILE -> $OUT"

# 参数检查
[ $# -eq 2 ] || { echo "Usage: $0 <dts> <img>"; exit 1; }
[ -f "$DTS_FILE" ] || { echo "❌ $DTS_FILE not found"; exit 1; }

# 临时 DTB 文件
TEMP_DTB=$(mktemp).dtb
trap "rm -f $TEMP_DTB" EXIT

# 1. 编译 DTS -> DTB
echo "📦 Compiling DTS -> DTB..."
dtc -I dts -O dtb -o "$TEMP_DTB" "$DTS_FILE" || {
    echo "❌ DTC failed"
    exit 1
}

DTB_SIZE=$(wc -c < "$TEMP_DTB")
echo "✅ DTB: ${DTB_SIZE} bytes"

# 2. 创建 DTBO（使用 mkdtboimg.py）
echo "🔨 Creating DTBO..."
python3 scripts/mkdtboimg.py create "$OUT" --page_size 4096 "$TEMP_DTB" || {
    echo "❌ mkdtboimg.py failed"
    exit 1
}

# 3. 验证输出
[ -f "$OUT" ] || { echo "❌ DTBO file not created"; exit 1; }
IMG_SIZE=$(wc -c < "$OUT")
echo "✅ DTBO: $OUT (${IMG_SIZE} bytes)"