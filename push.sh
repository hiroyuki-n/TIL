#!/usr/bin/env sh
# TIL: 作業ツリー全体 (git add -A) をコミットし origin にプッシュする
#
# 使い方:
#   ./push.sh "コミットメッセージ"  … 明示
#   ./push.sh                       … 日時の自動コミットメッセージ
# ターミナルに本ファイルのパスをドロップして Enter  … 上と同じ（引数なし）
# macOS では TIL-Sync.command のダブルクリックも可。
#
# 補足: ホーム等の global gitignore に *.md があると、
# 通常の git add では .md が取り込めません。本スクリプトでは .md を
# git add -f で再指定して追跡します。

set -eu

if [ -n "${1-}" ]; then
  msg="$*"
else
  msg="TIL: sync $(TZ=Asia/Tokyo date '+%Y-%m-%d %H:%M JST')"
  echo "（コミットメッセージ未指定のため次を使います） $msg" >&2
  echo "  付けたい場合: $0 \"TIL: 内容の要約\"" >&2
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
