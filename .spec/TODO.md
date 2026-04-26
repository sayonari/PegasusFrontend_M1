# TODO - タスクリスト

## 優先度：高
（なし）

## 優先度：中
- [x] パッチを再現可能な形（`.output/patches/m1-macos-build.patch`）に保存
- [x] `compile.sh` の wrapper を作って `qmake + make` を一発化（`pegasus-frontend/compile.sh`）

## 優先度：低
- [ ] サンプルテーマ／自前ROM での動作確認
- [ ] `Pegasus.app` への ad-hoc コード署名（Gatekeeper 回避）
- [ ] HANDOFF.md 更新

## 完了済み
- [x] 初期セットアップ
- [x] 環境調査（macOS 26.5 / M1 Max / Qt5.15.16 / SDL2 確認）
- [x] SPEC.md 作成
- [x] 公式リポジトリ clone（`pegasus-frontend/`、submodule 込み）
- [x] qmake 構成成功（pkg-config 経由 SDL2）
- [x] **C++17 への引き上げ**（4ファイル: `app.pro` `backend.pro` `frontend.pro` `qmltest_common.pri`）
- [x] **`/opt/homebrew/include` の include 順位問題解消**：SDL2 を `SDL_LIBS`/`SDL_INCLUDES` で明示渡し（pkg-config 経由だと brew Qt6 ヘッダが先に見えてしまう）
- [x] **AGL framework リンクエラー修正**（macOS 10.14 で削除済み）：`link_to_backend.pri` で `QMAKE_LIBS_OPENGL = -framework OpenGL` 上書き
- [x] make 完走、`Pegasus.app` 生成（arm64 ネイティブ、3.6MB）
- [x] CLI 起動 (`--help`) 確認
- [x] GUI 起動確認：Qt 5.15.16 / arm64 / cocoa / SDL 2.32.8 / Steam 9 ゲーム検出 OK
