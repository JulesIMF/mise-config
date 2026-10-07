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
