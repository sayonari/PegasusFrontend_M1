# KNOWLEDGE - ドメイン知識・調査結果

## 業務・ドメイン知識

- Pegasus Frontend は Qt/QML 製のレトロゲームランチャ。公式は qmake ビルド（CMake もあるが副）
- 公式 macOS CI（`.github/workflows/macos.yml`）は **Qt 5.15.10 + SDL 2.32.10** をプリビルドして使う方式（macos-13 = Intel）。Apple Silicon native は CI 対象外なので、こちらが事実上の M1 検証

## 環境（M1 Max / macOS 26.5 Tahoe）

- ビルド時に使用：
  - `/opt/homebrew/opt/qt@5/bin/qmake` （Qt 5.15.16, keg-only）
  - SDL2 `/opt/homebrew/Cellar/sdl2/2.32.8/`
  - Xcode CommandLineTools (clang++ Apple)
- 実行時の挙動：`Running on macOS 26.5 (arm64, cocoa)` / `Qt version 5.15.16` / `SDL version 2.32.8`

## ハマりどころ＆解決策（重要）

### 1. C++11 → C++17 への引き上げが必要
- 症状：`std::is_trivial_v` 等が見えず大量エラー
- 原因：Qt 5.15.16 のヘッダは C++17 機能を使用するが、Pegasus の `.pro` は `CONFIG += c++11`
- 対処：以下4ファイルで `c++11` → `c++17`
  - `src/app/app.pro`
  - `src/backend/backend.pro`
  - `src/frontend/frontend.pro`
  - `tests/qmltest_common.pri`

### 2. brew の Qt6 ヘッダが Qt5 より優先される（最大の落とし穴）
- 症状：`unknown type name 'QQuickImageProviderOptions'`、`QString` に `leftRef`/`midRef` が無い等
- 原因：pkg-config 経由 SDL2 だと `-I/opt/homebrew/include` が INCPATH 先頭に入り、ここの `QtCore/qglobal.h` が **Qt 6.9.1** のヘッダ（brew で qt 本家も入っているため）。結果 `QT_VERSION_MAJOR=6` となり Qt6 ブランチを誤って parse する
- **検出方法**：`clang++ -E -dM ... | grep QT_VERSION` で `QT_VERSION_MAJOR=6` が出たら確定
- 対処：qmake 引数で SDL2 を直接指定して `-I/opt/homebrew/include` を排除
  ```
  qmake .. USE_SDL_GAMEPAD=1 USE_SDL_POWER=1 \
       "SDL_LIBS=-L/opt/homebrew/lib -lSDL2" \
       SDL_INCLUDES=/opt/homebrew/include/SDL2
  ```

### 3. AGL framework リンクエラー
- 症状：`ld: framework 'AGL' not found`
- 原因：Qt 5.15 mkspec の `mac.conf` が `QMAKE_LIBS_OPENGL = -framework OpenGL -framework AGL` を持ち、AGL は macOS 10.14 で削除済み
- 対処：`src/link_to_backend.pri` の冒頭付近で
  ```
  macx: QMAKE_LIBS_OPENGL = -framework OpenGL
  ```
  を追加。⚠️ `LIBS -= -framework AGL` は使わない：トークン分解で `-framework Cocoa` の `-framework` を一緒に落とす副作用がある

### 4. SDL2 dylib の min macOS バージョン警告
- `ld: warning: building for macOS-11.0, but linking with dylib '...libSDL2-2.0.0.dylib' which was built for newer version 15.0`
- Qt mkspec の `-mmacosx-version-min=10.13` と brew SDL2 (15+) のミスマッチ。警告のみで実害なし

## ビルド再現手順（最短）

```bash
cd pegasus-frontend
# 1. パッチ適用済みであること（c++17, AGL fix）
# 2. ビルド
mkdir -p build && cd build
/opt/homebrew/opt/qt@5/bin/qmake .. \
    USE_SDL_GAMEPAD=1 USE_SDL_POWER=1 \
    "SDL_LIBS=-L/opt/homebrew/lib -lSDL2" \
    SDL_INCLUDES=/opt/homebrew/include/SDL2
make -j$(sysctl -n hw.ncpu)
# 3. 起動
open src/app/Pegasus.app
```

## 決定事項と理由

- **Qt5 を選択**（Qt6 ではなく）：Pegasus の API 想定が Qt5.15。Qt6 への移植は QStringRef/Gamepad モジュール関連で別タスク級
- **submodule 不採用、サブフォルダ clone**：親メタリポと pegasus-frontend のコミット履歴を独立に保つため。`.gitignore` で除外
- **パッチは pegasus-frontend 内ファイルを直接編集**：あくまでローカル検証のため。後で `.output/patches/*.patch` 化して再現性確保（TODO）
