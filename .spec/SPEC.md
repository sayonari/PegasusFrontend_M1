# SPEC - 技術仕様・要件定義

## 目的
Pegasus Frontend（公式: https://github.com/mmatyas/pegasus-frontend ）を
Apple Silicon (M1) Mac 上でクローン・ビルドし、`pegasus-fe.app` を起動できる状態にする。

## 機能要件
- 公式リポジトリを `pegasus-frontend/` サブフォルダにクローンする（最新 master）
- macOS arm64 ネイティブで `pegasus-fe.app` をビルドする
- ビルド後、`open pegasus-fe.app` で起動し初期画面の表示を確認する

## 非機能要件
- 親プロジェクト（PegasusFrontend_M1）の git は親側のみ管理。
  クローンされた `pegasus-frontend/` 配下は `.gitignore` で除外
- ビルド成果物（中間ファイル含む）は親リポジトリに混入させない
- パッチが必要な場合は `論文修正作業用スクリプト/` ではなく
  `.output/patches/` に保存し、適用手順を KNOWLEDGE.md に記録
- ROM/エミュレータの登録までは行わない（起動確認まで）

## 環境（実測）
| 項目 | 内容 |
|---|---|
| OS | macOS 26.5 (Tahoe) / Build 25F5058e |
| CPU | Apple M1 Max (arm64) |
| Homebrew | 5.1.7 @ /opt/homebrew |
| Qt 5 | 5.15.16 (keg-only) @ /opt/homebrew/opt/qt@5 |
| Qt 6 | 6.9.1（不使用、参考） |
| Xcode CLT | /Library/Developer/CommandLineTools |
| git | 2.50.1 (Apple Git-155) |
| cmake | 4.0.3 |
| SDL2 | 2.32.8 |
| 空きディスク | 約 550GB |

## 技術構成
- ビルドシステム：qmake（Pegasus 公式手順）
- Qt：`qt@5` 5.15.16（公式想定。Qt6 は互換性保証なし）
- ビルド方針：
  ```
  export PATH="/opt/homebrew/opt/qt@5/bin:$PATH"
  cd pegasus-frontend
  git submodule update --init --recursive
  mkdir build && cd build
  qmake .. USE_SDL_GAMEPAD=1 USE_SDL_POWER=1
  make -j$(sysctl -n hw.ncpu)
  ```
- 出力：`build/src/app/pegasus-fe.app`

## 想定リスク
- macOS 26 (Tahoe) は新しいSDKであり、Qt 5.15.16 の互換性に問題が出る可能性
- arm64 ネイティブビルド時のリンク／署名関連で警告／エラーの可能性
- C++ 言語仕様変更によるコンパイルエラー（いずれもパッチで対応見込み）

## 完了条件
- `pegasus-fe.app` が生成され、ダブルクリック／`open` で起動して
  Pegasus のランチャ画面（または「No games found」画面）が表示される
- 失敗した場合は原因と止まったステップを KNOWLEDGE.md に詳細記載
