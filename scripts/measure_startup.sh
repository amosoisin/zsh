#!/bin/bash
#
# Zsh起動時間測定スクリプト
#
# 使い方:
#   ./scripts/measure_startup.sh [回数]
#
# 例:
#   ./scripts/measure_startup.sh 10
#

set -e

# 測定回数（デフォルト: 10回）
ITERATIONS="${1:-10}"
OUTPUT_FILE="docs/performance.md"

echo "=== Zsh Startup Time Measurement ==="
echo "Iterations: ${ITERATIONS}"
echo ""

# 一時ファイル
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

# 測定実行
echo "Measuring zsh startup time..."
total=0
for i in $(seq 1 "$ITERATIONS"); do
    # timeコマンドで実時間を測定
    elapsed=$( (time zsh -i -c exit) 2>&1 | grep real | awk '{print $2}')
    echo "Run $i: $elapsed"
    echo "$elapsed" >> "$TEMP_FILE"
done

echo ""
echo "=== Results ==="

# 平均計算（秒に変換）
awk '
BEGIN {
    total = 0
    count = 0
}
{
    # mm:ss.sss形式をパース
    if ($0 ~ /[0-9]+m[0-9.]+s/) {
        split($0, parts, "m")
        minutes = parts[1]
        gsub(/s/, "", parts[2])
        seconds = parts[2]
        total += minutes * 60 + seconds
        count++
    }
    # ss.sss形式をパース
    else if ($0 ~ /^[0-9.]+s$/) {
        gsub(/s/, "", $0)
        total += $0
        count++
    }
}
END {
    if (count > 0) {
        avg = total / count
        printf "Average: %.3f seconds\n", avg
        printf "Total runs: %d\n", count

        # パフォーマンス評価
        if (avg < 0.3) {
            printf "Performance: Excellent\n"
        } else if (avg < 0.5) {
            printf "Performance: Good\n"
        } else if (avg < 1.0) {
            printf "Performance: Fair\n"
        } else if (avg < 2.0) {
            printf "Performance: Needs Improvement\n"
        } else {
            printf "Performance: Poor\n"
        }
    }
}
' "$TEMP_FILE"

echo ""
echo "Generating detailed report..."

# プラグイン別の読み込み時間を測定
PROF_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE" "$PROF_FILE"' EXIT

zsh -i -c "zmodload zsh/zprof; source ~/.zshrc; zprof" > "$PROF_FILE" 2>&1

echo ""
echo "=== Plugin Loading Times (Top 10) ==="
head -20 "$PROF_FILE" | tail -10 || echo "zprofデータの取得に失敗しました"

echo ""
echo "Full report saved to: $OUTPUT_FILE"

# パフォーマンスレポートを生成
cat > "$OUTPUT_FILE" <<EOF
# Zsh起動パフォーマンス測定結果

**測定日時:** $(date '+%Y-%m-%d %H:%M:%S')
**測定回数:** ${ITERATIONS}回

## 起動時間

\`\`\`
$(cat "$TEMP_FILE")
\`\`\`

## 統計

\`\`\`
$(awk '
BEGIN {
    total = 0
    count = 0
}
{
    if ($0 ~ /[0-9]+m[0-9.]+s/) {
        split($0, parts, "m")
        minutes = parts[1]
        gsub(/s/, "", parts[2])
        seconds = parts[2]
        time = minutes * 60 + seconds
        total += time
        times[count] = time
        count++
    }
    else if ($0 ~ /^[0-9.]+s$/) {
        gsub(/s/, "", $0)
        time = $0
        total += time
        times[count] = time
        count++
    }
}
END {
    if (count > 0) {
        avg = total / count
        printf "平均: %.3f 秒\n", avg
        printf "合計測定回数: %d\n", count

        # 最小・最大を計算
        min = times[0]
        max = times[0]
        for (i = 1; i < count; i++) {
            if (times[i] < min) min = times[i]
            if (times[i] > max) max = times[i]
        }
        printf "最小: %.3f 秒\n", min
        printf "最大: %.3f 秒\n", max

        # 標準偏差を計算
        sum_sq_diff = 0
        for (i = 0; i < count; i++) {
            diff = times[i] - avg
            sum_sq_diff += diff * diff
        }
        stddev = sqrt(sum_sq_diff / count)
        printf "標準偏差: %.3f 秒\n", stddev
    }
}
' "$TEMP_FILE")
\`\`\`

## プラグイン別読み込み時間

\`\`\`
$(cat "$PROF_FILE")
\`\`\`

## 評価基準

- **0.0 - 0.3秒**: Excellent ⭐⭐⭐⭐⭐ - 体感で遅延を感じない
- **0.3 - 0.5秒**: Good ⭐⭐⭐⭐ - わずかな遅延、実用上問題なし
- **0.5 - 1.0秒**: Fair ⭐⭐⭐ - 遅延を感じる、改善推奨
- **1.0 - 2.0秒**: Needs Improvement ⭐⭐ - 明らかに遅い、改善必要
- **2.0秒以上**: Poor ⭐ - 非常に遅い、早急な改善が必要

## 改善のヒント

起動時間が遅い場合、以下を試してください：

1. **zcompileの実施**
   \`\`\`bash
   ./scripts/zcompile_all.sh
   \`\`\`

2. **不要なプラグインの削除**
   - zshrcの\`plugins\`配列から使っていないプラグインを削除

3. **遅延読み込みの実装**
   - 重いツール（nvm、rbenv等）は必要時のみ読み込む

4. **プラグイン読み込み順序の最適化**
   - syntax-highlightingは最後に配置

詳細は[CLAUDE.md](../CLAUDE.md)の「パフォーマンス最適化」セクションを参照してください。

---

**次回測定:** 最適化実施後、再度測定して改善効果を確認
EOF

echo "Done!"
