#!/usr/bin/env sh
# TIL: 変更をまとめてコミットして origin にプッシュする
# 使い方: ./push.sh "コミットメッセージ"
# 例:     ./push.sh "TIL: Git のメモを追加"

set -eu

if [ -z "${1-}" ]; then
  echo "使い方: $0 <コミットメッセージ>" >&2
  echo "例:     $0 \"TIL: 学びのメモを追加\"" >&2
  exit 1
fi

# 常にリポジトリのルートで実行
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

msg="$*"
git add -A
if git diff --cached --quiet; then
  echo "コミットする変更がありません。" >&2
  exit 0
fi

git commit -m "$msg"
# 未追跡の main を初回だけ push する場合にも対応
current="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
if [ -z "$current" ] || [ "$current" = "HEAD" ]; then
  echo "ブランチが取得できません。gitの状態を確認してください。" >&2
  exit 1
fi

if git rev-parse --verify "origin/${current}" >/dev/null 2>&1; then
  git push
else
  git push -u origin "$current"
fi

echo "完了: リモートへプッシュしました。"
