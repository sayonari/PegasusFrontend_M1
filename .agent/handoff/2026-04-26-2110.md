# HANDOFF - 2026-04-26 21:10

## 使用ツール
Claude Code Opus 4.7 (1M context)

## 現在のタスクと進捗
- [x] Pegasus Frontend を M1 Mac (macOS 26.5 / arm64) でビルド・起動
  - **完了**：`pegasus-frontend/build/src/app/Pegasus.app` 生成、GUI 起動・Steam ライブラリ自動検出 OK

## 試したこと・結果

### 成功したアプローチ
1. 公式 https://github.com/mmatyas/pegasus-frontend をサブフォルダに `git clone --recursive`（親メタリポは独立、`.gitignore` で除外）
2. brew の `qt@5` 5.15.16 + SDL2 2.32.8 で qmake ビルド
3. **3つの修正パッチ**（`.output/patches/m1-macos-build.patch` に保存済み）を適用：
   - C++11 → C++17 への引き上げ（4ファイル）
   - AGL framework のリンク除去（macOS 10.14 で削除済み）
   - SDL2 を qmake 引数で明示渡し（pkg-config 経由だと brew Qt6 ヘッダが優先されてしまう）

### 失敗したアプローチ
- `LIBS -= -framework AGL` ：トークン分解で `-framework Cocoa` の `-framework` も落として別ビルドエラーを誘発した。`QMAKE_LIBS_OPENGL` 上書きのみが正解
- pkg-config 経由 SDL2 の素直ビルド：`-I/opt/homebrew/include` が INCPATH 先頭に入り、brew の qt 6.9.1 ヘッダを誤って読んで型エラー大量発生

## 次のセッションで最初にやること
1. パッチ（`.output/patches/m1-macos-build.patch`）を upstream PR として整形（必要に応じ）
2. `compile.sh` ラッパーを `pegasus-frontend/` 直下に作成すると、再ビルドが一行で済む
3. （任意）Pegasus 側で自分の Steam ライブラリ／ROM フォルダを設定して実用検証

## 注意点・ブロッカー
- macOS の Gatekeeper でユーザが直接ダブルクリック起動するとブロックされる可能性。`open Pegasus.app` でも警告出る場合は `xattr -cr Pegasus.app` で属性除去
- SDL2 dylib の min macOS バージョン警告（`macos-11.0` ターゲットに対し SDL2 が `15.0` 向け）は警告のみ、実害なし
- パッチは `pegasus-frontend/` のローカルファイルを直接編集している（git status で dirty）。上流に PR したい場合は `git checkout -b` してから `.output/patches/m1-macos-build.patch` を再適用するとよい
- `pegasus-frontend/` フォルダは親リポの `.gitignore` で除外済み（コミットされない）
