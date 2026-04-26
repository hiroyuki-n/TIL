#!/bin/bash
# macOS: このファイルをダブルクリックすると、TIL リポジトリを
# 保存・コミット・プッシュします（TIL フォルダ内に置いて使う想定）
cd "$(dirname "$0")" || exit 1
sh ./push.sh
st=$?
read -r -p "（終了コード: $st） Enter キーで閉じます" _
exit "$st"
