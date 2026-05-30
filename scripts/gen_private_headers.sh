#!/bin/bash
# 自动生成 Cyanide/tweaks/private/ 头文件

set -e

# 配置
PRIVATE_DIR="Cyanide/tweaks/private"
MAIN_FILE="Cyanide/SettingsViewController.m"
TEMP_FILE="required_headers.txt"

mkdir -p "$PRIVATE_DIR"

# 扫描需要的私有头文件
echo "=== 扫描私有头文件 ==="
grep -rh '#import "tweaks/private/' Cyanide/ --include="*.m" --include="*.h" 2>/dev/null | \
  sed -E 's/.*#import "tweaks\/private\/([^"]+\.h)".*/\1/' | sort -u > "$TEMP_FILE"

if [ ! -s "$TEMP_FILE" ]; then
  echo "无需生成私有头文件"
  exit 0
fi

echo "找到以下头文件:"
cat "$TEMP_FILE"

# 提取所有函数和常量（一次性扫描）
FUNCS_ALL=$(grep -oE '[a-z]+_[a-z_]+\\(' "$MAIN_FILE" 2>/dev/null | sed 's/($//' | sort -u)
CONSTS_ALL=$(grep -oE 'TYPEBANNER_RC_[A-Z_]+' "$MAIN_FILE" 2>/dev/null | sort -u)

# 头文件头部模板
read -r -d '' HEADER_TEMPLATE << 'EOF' || true
//
//  Auto-generated
//  Cyanide
//

#import <Foundation/Foundation.h>
@class RemoteCallSession;

EOF

# 生成每个头文件
while read -r header; do
  [ -z "$header" ] && continue
  name=$(basename "$header" .h)
  out="$PRIVATE_DIR/$header"
  
  # 写入头部
  echo "$HEADER_TEMPLATE" > "$out"
  
  # 筛选函数并生成宏
  echo "$FUNCS_ALL" | grep "^${name}_" | while read -r func; do
    case "$func" in
      *poll*)   echo "#define $func(...) nil" ;;
      *has*)    echo "#define $func(...) false" ;;
      *forget*) echo "#define $func(...)" ;;
      *)        echo "#define $func(...) true" ;;
    esac
  done >> "$out"
  
  # 无函数时生成默认存根
  if ! grep -q '^#define' "$out"; then
    cat >> "$out" << EOF
#define ${name}_apply_in_session(...) true
#define ${name}_stop_in_session(...) true
#define ${name}_forget_remote_state(...)
EOF
  fi
  
  # typebanner 常量
  if [ "$header" = "typebanner.h" ] && [ -n "$CONSTS_ALL" ]; then
    echo -e "\n// Constants" >> "$out"
    echo "$CONSTS_ALL" | while read -r c; do
      echo "#define $c 3000" >> "$out"
    done
  fi
  
  echo "✅ $header ($(grep -c '^#define' "$out") 宏)"
done < "$TEMP_FILE"

# 清理
rm -f "$TEMP_FILE"
echo "=== 生成完成 ==="
ls -la "$PRIVATE_DIR"