# HANDOFF - 2026-04-26 21:38

## 使用ツール
Claude Code Opus 4.7 (1M context)

## 現在のタスクと進捗
- [x] Pegasus Frontend を M1 Mac (macOS 26.5 / arm64) でビルド・起動
- [x] 修正パッチをフォークに公開、Actions でバイナリ自動配布

## 公開リソース
| 種類 | URL |
|---|---|
| メタリポ | https://github.com/sayonari/PegasusFrontend_M1 |
| パッチ済みフォーク | https://github.com/sayonari/pegasus-frontend |
| 最新リリース | https://github.com/sayonari/pegasus-frontend/releases/tag/v0.0.2-m1 |
| バイナリ直リンク | https://github.com/sayonari/pegasus-frontend/releases/download/v0.0.2-m1/pegasus-fe_v0.0.1-m1-1-gd99c265e_macos-arm64.zip |

## 試したこと・結果

### 成功
- ローカルビルド：upstream `6740ab65` + 3パッチで `Pegasus.app` arm64 native（Steam 9 ゲーム検出済み）
- フォーク `sayonari/pegasus-frontend` master：upstream + 3コミット（コード修正 / フォーク用ファイル / CI 権限修正）
- CI（macos-14 ランナー）：~2 分でビルド完走
- Release 自動公開：v0.0.2-m1 で 1.5MB の zip 配布開始

### 失敗とリカバリ
- **v0.0.1-m1 タグ**：CI ビルド成功も `Publish release on tag` で `Resource not accessible by integration`。原因はフォーク repo の `GITHUB_TOKEN` がデフォルトで read-only。
- **対処**：ワークフローに `permissions: contents: write` を追加して push、`v0.0.2-m1` で再タグ → 成功。

## 次のセッションで最初にやること
1. 自分の Steam ライブラリ／ROM フォルダを Pegasus に登録して実用検証
2. （任意）Node.js 20 deprecation 対応：`actions/checkout@v4` → `@v5` 等へバンプ（締切 2026-06-02）
3. （任意）upstream の追従：`git fetch upstream && git rebase upstream/master` でパッチを最新の master に乗せ直し

## 注意点・ブロッカー
- macOS Gatekeeper：未署名なので `xattr -cr Pegasus.app` で属性除去するとダブルクリック起動可
- `pegasus-frontend/` ローカルディレクトリは親メタリポでは `.gitignore` 済み。`fork` の作業ディレクトリとして残してある
- `pegasus-frontend/` の git remotes：`origin` = フォーク、`upstream` = mmatyas/pegasus-frontend
