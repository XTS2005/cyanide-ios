#!/bin/bash
# 自动生成 Cyanide/tweaks/private/ 头文件

set -e

PRIVATE_DIR="Cyanide/tweaks/private"
MAIN_FILE="Cyanide/SettingsViewController.m"

mkdir -p "$PRIVATE_DIR"

# 扫描需要的私有头文件
echo "=== 扫描私有头文件 ==="
grep -rh '#import "tweaks/private/' Cyanide/ --include="*.m" --include="*.h" 2>/dev/null | \
  sed -E 's/.*#import "tweaks\/private\/([^"]+\.h)".*/\1/' | sort -u > headers.txt

if [ ! -s headers.txt ]; then
  echo "无需生成私有头文件"
  rm -f headers.txt
  exit 0
fi

echo "找到以下头文件:"
cat headers.txt

# 提取所有函数和常量
FUNCS_ALL=$(grep -oE '[a-z]+_[a-z_]+\\(' "$MAIN_FILE" 2>/dev/null | sed 's/($//' | sort -u)
CONSTS_ALL=$(grep -oE 'TYPEBANNER_RC_[A-Z_]+' "$MAIN_FILE" 2>/dev/null | sort -u)

# 生成每个头文件
while IFS= read -r header; do
  [ -z "$header" ] && continue
  name=$(basename "$header" .h)
  out="$PRIVATE_DIR/$header"
  
  echo "生成: $header"
  
  # 写入头部
  cat > "$out" << 'EOF'
//
//  Auto-generated
//  Cyanide
//

#import <Foundation/Foundation.h>
@class RemoteCallSession;

EOF
  
  # 生成函数宏
  HAS_FUNC=0
  while IFS= read -r func; do
    HAS_FUNC=1
    case "$func" in
      *poll*)   echo "#define $func(...) nil" ;;
      *has*)    echo "#define $func(...) false" ;;
      *forget*) echo "#define $func(...)" ;;
      *)        echo "#define $func(...) true" ;;
    esac
  done < <(echo "$FUNCS_ALL" | grep "^${name}_") >> "$out"
  
  # 默认存根
  if [ $HAS_FUNC -eq 0 ]; then
    echo "#define ${name}_apply_in_session(...) true" >> "$out"
    echo "#define ${name}_stop_in_session(...) true" >> "$out"
    echo "#define ${name}_forget_remote_state(...)" >> "$out"
  fi
  
  # typebanner 常量
  if [ "$header" = "typebanner.h" ] && [ -n "$CONSTS_ALL" ]; then
    echo "" >> "$out"
    echo "// Constants" >> "$out"
    while IFS= read -r const; do
      echo "#define $const 3000" >> "$out"
    done < <(echo "$CONSTS_ALL")
  fi
  
  echo "  ✅ 完成 ($(grep -c '^#define' "$out") 个宏)"
done < headers.txt

rm -f headers.txt
echo "=== 生成完成 ==="
ls -la "$PRIVATE_DIR"
