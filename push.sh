#!/usr/bin/env sh
# TIL: 変更をまとめてコミットして origin にプッシュする
# 使い方: ./push.sh "コミットメッセージ"
# 例:     ./push.sh "TIL: Git のメモを追加"
#
# 補足: ホーム等の global gitignore に *.md があると、
# 通常の git add では .md が取り込めません。本スクリプトでは .md を
# git add -f で再指定して追跡します。

set -eu

if [ -z "${1-}" ]; then
  echo "使い方: $0 <コミットメッセージ>" >&2
  echo "例:     $0 \"TIL: 学びのメモを追加\"" >&2
  exit 1
fi

# 常に push.sh があるディレクトリをルートにする
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "error: ここは Git リポジトリではありません: $ROOT" >&2
  exit 1
fi

git add -A
# グローバルな gitignore 等で *.md が除外されていても、リポ内の .md を追跡
find . -not -path '*/.git/*' -name "*.md" -type f -exec git add -f -- {} + 2>/dev/null || true

msg="$*"
echo "---- 次をコミットするファイル (staged) ----" >&2
git diff --cached --name-only || true
if git diff --cached --quiet; then
  echo "コミットする変更がありません。" >&2
  echo "  - エディタで .md の保存 (Cmd+S) を確認してください。" >&2
  echo "  - いま編集しているのがこのリポジトリ内か確認してください: $ROOT" >&2
  echo "" >&2
  git status -s >&2
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
