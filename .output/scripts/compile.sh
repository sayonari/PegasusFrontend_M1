#!/bin/bash
# Pegasus Frontend - M1 Mac (Apple Silicon) build script
#
# Usage:
#   ./compile.sh           # Incremental build (configure once, then make)
#   ./compile.sh --clean   # Wipe build/ and re-configure from scratch
#   ./compile.sh --run     # Build, then launch Pegasus.app
#
# Requirements (Homebrew on Apple Silicon):
#   brew install qt@5 sdl2

set -e

cd "$(dirname "$0")"

QT5_QMAKE="/opt/homebrew/opt/qt@5/bin/qmake"
SDL2_PREFIX="/opt/homebrew"

if [ ! -x "$QT5_QMAKE" ]; then
    echo "Error: qt@5 qmake not found at $QT5_QMAKE"
    echo "Install with: brew install qt@5"
    exit 1
fi

if [ ! -d "${SDL2_PREFIX}/include/SDL2" ]; then
    echo "Error: SDL2 headers not found at ${SDL2_PREFIX}/include/SDL2"
    echo "Install with: brew install sdl2"
    exit 1
fi

CLEAN=0
RUN_AFTER=0
for arg in "$@"; do
    case "$arg" in
        --clean|-c) CLEAN=1 ;;
        --run|-r)   RUN_AFTER=1 ;;
        --help|-h)
            sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *) echo "Unknown option: $arg"; exit 2 ;;
    esac
done

if [ "$CLEAN" = "1" ]; then
    echo "[clean] removing build/"
    rm -rf build
fi

mkdir -p build
cd build

if [ ! -f Makefile ] || [ "$CLEAN" = "1" ]; then
    echo "[configure] qmake .."
    "$QT5_QMAKE" .. \
        USE_SDL_GAMEPAD=1 USE_SDL_POWER=1 \
        "SDL_LIBS=-L${SDL2_PREFIX}/lib -lSDL2" \
        "SDL_INCLUDES=${SDL2_PREFIX}/include/SDL2"
fi

NCPU=$(sysctl -n hw.ncpu)
echo "[build] make -j${NCPU}"
make -j"$NCPU"

APP_PATH="src/app/Pegasus.app"
echo ""
echo "=== Build finished ==="
if [ -d "$APP_PATH" ]; then
    APP_ABS="$(cd "$APP_PATH/.." && pwd)/Pegasus.app"
    echo "Output: $APP_ABS"
    if [ "$RUN_AFTER" = "1" ]; then
        echo "[run] open $APP_ABS"
        open "$APP_ABS"
    else
        echo "Run:    open '$APP_ABS'"
    fi
else
    echo "Error: Pegasus.app not produced. See output above."
    exit 1
fi
