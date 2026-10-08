# Консольная конфигурация mise

Этот каталог — копия исходника `~/.config/mise/`. На рабочем Ubuntu 22.04 ПК конфигурация применена 2026-10-07: пользовательский zsh, 26 CLI через mise, Docker Engine/Compose и семь системных CLI для root. Профиль личного Apple Silicon Mac сопоставлен с реальной системой 2026-10-08; инвентаризация и решения записаны в `inventory.md`. Актуальное состояние проверяется через `mise bootstrap plan`, `mise dot status` и удалённый репозиторий.

Порядок выбора профилей и первого запуска на новом устройстве: [DEPLOY.md](DEPLOY.md).

## Состав

`miserc.toml` включает автоматический выбор `config.linux.toml` или `config.macos.toml`; `conf.d/modern/` загружается всегда. В `miserc.local.toml` каждой машины задаётся локальный список `env` и этот файл не сохраняется в репозитории. Пример: `miserc.local.toml.example`. Совпадающие ключи профилей сливаются в порядке `env`.

| Профиль | Назначение |
| --- | --- |
| `config.toml`, `shell/base.zsh` | zsh, промпт и общие функции `wdcopy`, `pcopy`, `today`, `mz` |
| `conf.d/modern/` | базовые современные CLI, Rust для Cargo-инструментов, алиасы, инициализация и отдельный option completion |
| `linux`, `macos` | системные zsh, git, curl, jq; на Mac btop через Homebrew и интеграция OrbStack |
| `host`, `server`, `container` | роль машины; Docker daemon в dev-контейнере не запускается |
| `work`, `personal` | принадлежность машины; рабочие локальные настройки остаются вне репозитория |
| `ubuntu-desktop` | xclip и алиасы `pbcopy`/`pbpaste` только в локальной графической сессии Ubuntu |
| `docker-ubuntu` | официальный APT-репозиторий Docker, Engine, Compose и service |
| `docker-macos` | OrbStack для поддерживаемого Apple Silicon Mac |
| `node` | Node и `npm:@openai/codex`; nvm и Cline сохранены на диске, но не подключаются |
| `modern-extra` | дополнительные Cargo CLI |
| `yandex-cloud`, `skotty` | отдельные включаемые интеграции |
| `root/` | системные modern CLI и отдельный zsh root |

На текущем ПК выбран `work + host + ubuntu-desktop + docker-ubuntu + node + modern-extra + yandex-cloud + skotty`. Версии `latest` плавающие, lockfile не используется. Повторный `mise bootstrap` должен применять только расхождения; `mise install` при тех же разрешённых версиях ничего повторно не собирает. Обновления при новом релизе могут менять систему, поэтому перед ними полезен `mise bootstrap plan`.

На личном Mac выбран `personal + host + node + docker-macos + modern-extra + yandex-cloud`. `btop` из Aqua поддерживает только Linux, поэтому на Mac он ставится как `brew:btop`; уже установленный OrbStack сохраняется.

Mac-профиль добавляет `opt/curl/bin` и `opt/btop/bin` в PATH через `env._.path`: curl у Homebrew keg-only, а btop должен иметь приоритет над сохранёнными Cargo-бинарниками и их shims.

## Промпт и zsh

Новая оболочка показывает `(zsh) user path %`, `(zsh docker <container>) user path %` или `(zsh remote <hostname>) user path %`. В контейнере сначала используется `CONTAINER_NAME`, затем `hostname`, который может быть ID. Передайте `CONTAINER_NAME`, если требуется читаемое имя. Контейнер имеет приоритет над SSH.

`shell/base.zsh` добавляет `~/.zfunc`, `~/.local/share/zsh/site-functions` и Homebrew `site-functions` в `fpath` до `compinit`. Файлы completion, созданные установщиками, остаются локальными и не отслеживаются. Собственные переносимые completion можно добавить в `dotfiles` соответствующего профиля. `conf.d/modern/shell/modern-option-completion.zsh` содержит запасные правила и не заменяет специализированные completion, кроме явного исправления `delta`.

Yandex Cloud использует собственный generated completion, который повторно вызывает `compinit`; после него повторно применяются только общие правила completion, без второй инициализации CLI.

На всех машинах история zsh использует `~/.histfile`, `ls` вызывает `eza --hyperlink=auto`, а Atuin отвечает за ↑ и Ctrl+R. Существующие файлы истории не сливаются и не удаляются. Алиасы Mac (`eza`, цветные `grep`/`egrep`/`fgrep`, `diff`, `tree`, `xxd`, `hl`) объединены с общими: необязательные команды и поддержка цвета в `xxd` проверяются. Цветной `ip` включается только на Linux: iproute2mac не поддерживает цвет и предупреждает при `-color`.

`shell/macos.zsh` подключается из управляемого блока `.zprofile` и перед `compinit` в интерактивном zsh. Он сохраняет Homebrew PATH, `HOMEBREW_NO_AUTO_UPDATE=1` и installer-owned интеграцию OrbStack, убирая повторные записи PATH/fpath.

Проверка активного shell после bootstrap: `zsh -ilc 'source ~/.config/mise/tests/shell.zsh'`. Запускайте в терминале, чтобы Atuin/fzf могли настроить ZLE; тест подменяет clipboard backend только внутри своей оболочки и не меняет системный буфер обмена.

Для нового инструмента с `tool init zsh` добавьте условный вызов в подходящий shell-модуль, затем удалите старую строку из личного `.zshrc`, чтобы не было двойной инициализации. Рабочие `rwt`, `zp`, `sdtool` живут только в `~/.config/julesimf-shell/work-local.zsh`. Mise подключает этот файл, но не хранит его содержимое. Его нужно создать локально на каждом рабочем устройстве.

Node берётся из mise. Нынешние каталоги nvm и установленный там Cline сохраняются. Corepack пока не включён. IDE, Ghidra и Android SDK не загружаются при каждом запуске shell. `MALEVICH_PATH` и рабочий PATH оставлены в локальном рабочем файле.

## Применение на Ubuntu

Перед первой миграцией сохраните копию `.zshrc` и проверьте `mise bootstrap plan`. На текущем ПК копия лежит в `~/.zshrc.pre-mise-2026-10-07`. Для нового Ubuntu с Docker нужен `mise bootstrap --update`: ключ и `.sources` создаются в фазе `pre-packages`, затем APT обновляет индексы. На текущем ПК прежний `/etc/apt/sources.list.d/docker.list` удалён после проверки его эквивалентности новому `.sources`.

На новом Linux-хосте Docker-профиль добавляет пользователя bootstrap в группу `docker`, если его там ещё нет. На текущем ПК запись группы уже существует, но действующий процесс получил старый список групп: нужен новый вход. Участники группы `docker` получают привилегии уровня root через сокет Docker.

Для root используется отдельный `root/config.toml` в `/root/.config/mise/`, бинарник mise в системном PATH, system install для набора CLI, файлы `root/modern-root.zsh` и `modern-option-completion.zsh` в `/etc/julesimf-shell/`. В `/root/.zshrc` добавляется `root/zshrc-snippet.zsh`. На новом Linux-хосте эти шаги выполняет `root/install.sh` после основного bootstrap. Пользовательский `.zshrc` root не источает.

## Сохранение и добавление программ

Сначала проверьте `mise dot status` и список отслеживаемых файлов: `miserc.local.toml`, локальный рабочий shell-файл и generated completion не должны попасть в Git. Затем установите ручной режим: `mise dot origin set git@github.com:JulesIMF/mise-config.git --sync manual`. После проверки применённой конфигурации выполните `mise dot save ~/.config/mise` и `mise dot sync`. Путь нужен из-за `autosave = false`. Автоматической синхронизации, установки или обнаружения новых пакетов нет. Новую программу добавляют в подходящий профиль и запускают `mise bootstrap plan` / `mise bootstrap` на нужном устройстве.

Серверы и контейнеры ещё требуют проверки на месте. Mac-профиль Docker использует OrbStack и рассчитан на Apple Silicon. Локальные `miserc.local.toml` на других машинах следует сформировать из примера, выбрав только нужные роли.
