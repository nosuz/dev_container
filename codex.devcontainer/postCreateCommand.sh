#!/usr/bin/bash

set -eu

# チェック対象のディレクトリとマーカーファイル
MARKER_FILE="$HOME/.postCreateCommand-done"

if [ -f "$MARKER_FILE" ]; then
  # マーカーファイルがあれば終了
  exit 0
elif [ ! -w "$HOME" ]; then
  # ホームに書き込めない時は、異常終了
  echo "ホームディレクトリが書き込めません。"
  exit 1
fi

# 初期化スクリプトを実行

mkdir -p /workspaces/.codex
ln -sfn /workspaces/.codex ~/.codex

mkdir -p /workspaces/.claude
ln -sfn /workspaces/.claude ~/.claude

# 初期化完了を示すマーカーファイルを作成
touch "$MARKER_FILE"
