# Pegasus Frontend on Apple Silicon (M1) Mac

Build notes, patches, and a one-shot compile script for getting
[Pegasus Frontend](https://github.com/mmatyas/pegasus-frontend) running
**natively on Apple Silicon Macs (M1/M2/M3) with modern macOS** (tested on macOS 26 Tahoe).

> 📦 If you just want a ready-to-use binary, grab the latest release from
> [sayonari/pegasus-frontend → Releases](https://github.com/sayonari/pegasus-frontend/releases).
> The patched source lives in that fork as well.

This meta-repo contains:

- `.spec/KNOWLEDGE.md` — write-up of three M1-specific build issues and how to fix them
- `.output/patches/m1-macos-build.patch` — the patch set against upstream
- `.output/scripts/compile.sh` — convenience build wrapper (also lives in the fork)
- `.spec/SPEC.md` — full environment requirements
- `.agent/` / `.spec/` / `CLAUDE.md` etc. — AI-assisted dev workflow scaffolding

## Quick start

```bash
brew install qt@5 sdl2
git clone --recursive https://github.com/sayonari/pegasus-frontend.git
cd pegasus-frontend
./compile.sh
open build/src/app/Pegasus.app
```

That's it. The script handles the qmake invocation with all the M1-specific
workarounds baked in.

## What's the catch on M1 Mac?

Three things break a stock `qmake && make` against Homebrew's `qt@5` 5.15.16:

| # | Symptom | Root cause | Fix |
|---|---|---|---|
| 1 | `std::is_trivial_v` not found, fold expressions unknown | Pegasus declares `c++11`, but Qt 5.15.16 (KDE-patched maintenance release) headers use C++17 features | Bump `CONFIG += c++17` in 4 `.pro`/`.pri` files |
| 2 | `unknown type name 'QQuickImageProviderOptions'`, `QString` has no `leftRef` | `pkg-config sdl2` returns `-I/opt/homebrew/include` which lands first in `INCPATH`, ahead of `qt@5`'s framework headers — and `/opt/homebrew/include` belongs to brew's **`qt` 6.9.1**! Compiler ends up parsing Qt 6 headers as if it were Qt 5 | Bypass pkg-config; pass `SDL_LIBS`/`SDL_INCLUDES` to qmake directly |
| 3 | `ld: framework 'AGL' not found` | Qt 5.15 mkspec still references the AGL framework, which Apple removed in macOS 10.14 | Override `QMAKE_LIBS_OPENGL = -framework OpenGL` |

Full investigation in [`.spec/KNOWLEDGE.md`](.spec/KNOWLEDGE.md).

## Tested environment

- macOS 26.5 (Tahoe), Apple M1 Max
- Homebrew `qt@5` 5.15.16, `sdl2` 2.32.8
- Xcode CommandLineTools (clang++)
- `pegasus-frontend` upstream commit `6740ab65` (alpha16-97, 2026-04-12)

The CI workflow in the fork runs `macos-14` (Apple Silicon) so binaries are
arm64-native. Verified output: `Mach-O 64-bit executable arm64`.

## License

This meta-repo (build scripts, notes, patches) is published under MIT.
See [`LICENSE`](LICENSE).

The patches in `.output/patches/` apply to **Pegasus Frontend**, which is
licensed under **GPLv3**. Any derivative work that includes Pegasus source
(such as the [fork](https://github.com/sayonari/pegasus-frontend) or its
release binaries) is bound by GPLv3 — see that repository's `LICENSE.md`
and `MODIFICATIONS.md`.

## Acknowledgements

Pegasus Frontend is the work of Mátyás Mustoha and contributors:
<https://github.com/mmatyas/pegasus-frontend>. This repo only documents
how to build it on a platform the upstream CI doesn't yet cover.

If any of the patches here turn out to be useful upstream, the maintainer
is welcome to lift them — they were written specifically with that intent.
