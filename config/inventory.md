# Инвентаризация исходного Ubuntu ПК

Снимок до миграции, 2026-10-07. Пакеты текущего устройства сами по себе не означают, что они нужны другим устройствам.

| Источник | Найдено | Решение |
| --- | --- | --- |
| APT | zsh, git, git-lfs, curl, jq, xclip, Docker CE/Compose и многие системные пакеты | основа в Linux-профиле; git-lfs в work; xclip в ubuntu-desktop; Docker в docker-ubuntu |
| Cargo и локальные бинарники | atuin, bat, broot, difftastic, dust, dua-cli, eza, delta, hyperfine, just, ouch, procs, sd, tlrc, tokei, xcp, xh, zoxide, fzf, btop, duf | большая часть в modern; procs/ouch/dua-cli/xcp в modern-extra; рабочий sdtool не управляется |
| nvm/npm | Node 22.13.1, Codex, Cline, Corepack | Node и Codex в `node`; nvm/Cline сохранены, но отключены от zsh; Corepack позже |
| Go | dlv, gopls и другие рабочие утилиты | пока локально, без общего профиля |
| Desktop и IDE | Ghidra, Android Studio, IntelliJ, Android SDK | не добавлены в startup zsh |

Исходный `.zshrc` и `.zshenv` сохранены перед миграцией. В `~/.zfunc` и `~/.local/share/zsh/site-functions` были локальные completion, включая `_arc`, `_atuin`, `_br`, `_broot`, `_delta`, `_duf`, `_dust`, `_eza`, `_lnav`, `_ouch`, `_procs`, `_sd`, `_tldr`, `_xh`, `_zoxide` и `_ya`. Их содержимое mise не отслеживает. `~/.zshenv` по-прежнему загружает Cargo env; дублирование в `.zshrc` убрано.

## Личный Apple Silicon Mac

Снимок до миграции, 2026-10-08: arm64, macOS 27.0, login shell `/bin/zsh`; mise отсутствовал. Выбраны `personal`, `host`, `node`, `docker-macos`, `modern-extra`, `yandex-cloud`.

| Источник | Найдено | Решение |
| --- | --- | --- |
| macOS | системные zsh, Apple Git 2.54.0, curl 8.7.1 | login shell остаётся `/bin/zsh`; git/curl/jq через Mac-профиль |
| Homebrew `/opt/homebrew` | Node 23.2.0, fd, ripgrep, colordiff, highlight, iproute2mac, tree; множество проектных SDK и библиотек | modern CLI и Node получают приоритет через mise; старые пакеты не удаляются, весь Brew inventory автоматически не переносится |
| Cargo и локальные бинарники | большинство базовых modern CLI, Rust 1.95.0, Atuin 18.23.0, broot 1.60.2, eza 0.23.5, btop 1.4.7; ouch/procs/xcp | основной набор и modern-extra через mise; Cargo env остаётся в `.zshenv`, старые бинарники сохраняются |
| OrbStack | cask 2.0.5, действующий installer-owned `~/.orbstack/shell/init.zsh` | существующее приложение сохраняется; PATH и completion загружаются Mac shell-модулем |
| Yandex Cloud | `~/yandex-cloud`, PATH и zsh completion | профиль `yandex-cloud`; файлы установщика не отслеживаются |
| Bash | старые Linux-derived startup-файлы, ghcup и git completion; ссылки на отсутствующие clos и VK Cloud | Bash-файлы не меняются; в активный zsh эти старые интеграции не добавляются |
| История | существуют `~/.histfile` и `~/.zsh_history` | содержимое не читается и не сливается; zsh продолжает использовать `~/.histfile` |

Согласованные пользователем различия: `ls → eza --hyperlink=auto` везде; Atuin на ↑ и Ctrl+R везде; общий `HISTFILE=~/.histfile`. Цветной `ip` оставлен только на Linux: настоящий iproute2mac предупреждает, что цвет не реализован. Уникальные zsh-алиасы Mac объединены с общими, для платформенных/необязательных инструментов добавлены проверки. Bash launcher broot заменён нативной инициализацией zsh. Цвет Git уже настроен глобально (`color.ui=auto`), повторный `git config` при каждом старте shell убран.

Оригинальные `.zshrc`, `.zprofile` и `.zshenv` сохранены в `~/.config/mise-migration-backup-2026-10-08/`. Локальные профили и настройки ручной синхронизации остаются в `miserc.local.toml` и `config.local.toml`, вне истории mise.

При проверке фактического PATH обнаружены keg-only curl и старый Cargo btop, доступный через Rust shims. Mac-профиль явно добавляет Brew `opt/curl/bin` и `opt/btop/bin`. Generated completion Yandex Cloud сбрасывал `_comps[eza]` при повторном `compinit`; после него общие правила completion применяются заново.

Проверка после применения: mise 2026.10.3, 25 инструментов mise, Git 2.56.0, curl 8.22.0, jq 1.8.2, Brew btop 1.4.7, Node 26.11.1, Codex 0.160.1, Rust stable 1.99.0. Каждый modern CLI успешно запущен на этом Mac; некоторые upstream-релизы (dust/hyperfine) поставляют macOS x86_64-бинарники, которые здесь работают через Rosetta. Интерактивные login и non-login zsh проходят `tests/shell.zsh`; отдельно проверены SSH-промпт и приоритет контейнера. `mise bootstrap plan` показывает ноль изменений, повторный полный bootstrap устанавливает ноль инструментов, все управляемые dotfiles применены.
