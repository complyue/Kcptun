#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_FILE="$SCRIPT_DIR/Kcptun.xcodeproj"
SCHEME="KcpProxy"
CONFIGURATION="Release"

echo "🔧 KcpProxy Release 版本安装脚本"
echo "=================================="
echo ""

if [ ! -d "$PROJECT_FILE" ]; then
    echo "❌ 错误: 找不到项目文件 $PROJECT_FILE"
    exit 1
fi

echo "🔍 正在查找 Release 构建产物..."

DERIVED_DATA_BASE="$HOME/Library/Developer/Xcode/DerivedData"

if [ -d "$DERIVED_DATA_BASE" ]; then
    RELEASE_APP=$(find "$DERIVED_DATA_BASE" \
        -name "${SCHEME}.app" \
        -path "*/Build/Products/${CONFIGURATION}/*" \
        -type d 2>/dev/null | head -1)
fi

if [ -z "$RELEASE_APP" ] && [ -f "$PROJECT_FILE" ]; then
    echo "📝 尝试通过 xcodebuild 获取路径..."
    
    BUILD_SETTINGS=$(xcodebuild -project "$PROJECT_FILE" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -showBuildSettings 2>/dev/null) || true
    
    BUILT_PRODUCTS_DIR=$(echo "$BUILD_SETTINGS" | \
        grep "^BUILT_PRODUCTS_DIR" | \
        awk -F'= ' '{print $2}' | \
        head -1)
    
    PRODUCT_NAME=$(echo "$BUILD_SETTINGS" | \
        grep "^PRODUCT_NAME" | \
        awk -F'= ' '{print $2}' | \
        head -1)
    
    if [ -n "$BUILT_PRODUCTS_DIR" ] && [ -n "$PRODUCT_NAME" ]; then
        RELEASE_APP="$BUILT_PRODUCTS_DIR/$PRODUCT_NAME.app"
    fi
fi

if [ -z "$RELEASE_APP" ]; then
    echo ""
    echo "❌ 错误: 找不到 Release 版本"
    echo ""
    echo "请先编译 Release 版本:"
    echo "   cd $SCRIPT_DIR"
    echo "   xcodebuild -project $PROJECT_FILE -scheme $SCHEME -configuration $CONFIGURATION build"
    exit 1
fi

if [ ! -d "$RELEASE_APP" ]; then
    echo "❌ 错误: Release 版本不存在于 $RELEASE_APP"
    echo "请先运行 xcodebuild 编译 Release 版本"
    exit 1
fi

TARGET_PATH="/Applications/${SCHEME}.app"

echo "✅ 找到 Release 构建:"
echo "   📦 源文件: $RELEASE_APP"
echo "   🎯 目标位置: $TARGET_PATH"
echo ""

if [ -d "$TARGET_PATH" ]; then
    echo "⚠️  发现旧版本，正在删除..."
    rm -rf "$TARGET_PATH"
    echo "✅ 旧版本已删除"
fi

echo "📋 正在安装新版本..."
cp -R "$RELEASE_APP" "$TARGET_PATH"

echo ""
echo "✅ 安装完成！"
echo ""
echo "📊 安装信息:"
ls -lh "$TARGET_PATH" | awk '{print "   大小: " $5}'
du -sh "$TARGET_PATH" | awk '{print "   总大小: " $1}'
echo ""
echo "🚀 现在可以启动应用了:"
echo "   open $TARGET_PATH"
echo ""