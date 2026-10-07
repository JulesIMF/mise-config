# Развёртывание на новой машине

Первичный минимум: Git, mise, доступ по SSH к `git@github.com:JulesIMF/mise-config.git` и права `sudo` для системных пакетов. На Ubuntu Git/curl можно поставить через `sudo apt-get update && sudo apt-get install -y git curl ca-certificates`. На Mac проверьте `git --version`; если macOS предлагает Command Line Tools, установите их. На Apple Silicon отдельная установка Homebrew для профилей `brew:`/`brew-cask:` не нужна: mise использует встроенный менеджер.

## 1. Установить mise и выбрать профили

```sh
curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
git ls-remote git@github.com:JulesIMF/mise-config.git HEAD

mkdir -p "$HOME/.config/mise"
cat > "$HOME/.config/mise/config.local.toml" <<'EOF'
[settings.history]
sync = "manual"
EOF
cat > "$HOME/.config/mise/miserc.local.toml" <<'EOF'
env = ["work", "host", "ubuntu-desktop", "docker-ubuntu", "node", "modern-extra", "yandex-cloud", "skotty"]
EOF
```

Замените строку `env` на нужную комбинацию **до** первого bootstrap. Общий modern CLI модуль и профиль ОС (`linux`/`macos`) подхватятся автоматически; остальные профили задаются явно. Примеры:

| Машина | `env` |
| --- | --- |
| Рабочий Ubuntu ПК, как текущий | `["work", "host", "ubuntu-desktop", "docker-ubuntu", "node", "modern-extra", "yandex-cloud", "skotty"]` |
| Личный Ubuntu ПК без Docker | `["personal", "host", "ubuntu-desktop", "node"]` |
| Рабочий Ubuntu сервер с Docker | `["work", "server", "docker-ubuntu"]` |
| Рабочий Mac с Apple Silicon | `["work", "host", "node", "docker-macos"]` |
| Личный Mac с Apple Silicon | `["personal", "host", "node"]` |
| Рабочий dev-контейнер | `["work", "container", "node"]` |

`docker-ubuntu` запускает Docker Engine на Ubuntu, `docker-macos` ставит OrbStack на Apple Silicon. В dev-контейнере отдельный Docker daemon не предусмотрен. `ubuntu-desktop` включает графические алиасы `pbcopy`/`pbpaste`. `modern-extra` добавляет четыре Cargo CLI; Rust для базовых Atuin/tokei ставится и без него. `work-local.zsh` с рабочими скриптами и секретами нужно создать отдельно на каждой рабочей машине; mise лишь подключит его, если файл существует.

## 2. Применить сохранённую конфигурацию

На Ubuntu с `docker-ubuntu` обновите APT-индексы при первом применении нового репозитория:

```sh
mise bootstrap --adopt git@github.com:JulesIMF/mise-config.git --update --dry-run
mise bootstrap --adopt git@github.com:JulesIMF/mise-config.git --update
```

На Mac и на Linux без нового APT-репозитория опустите `--update`. Перед применением сохраните старый `.zshrc`: mise добавит свои управляемые блоки, но не удалит старые строки инициализации nvm/fzf/zoxide/atuin. После проверки удалите дублирующиеся старые строки вручную. Если у машины уже есть конфликтующий `~/.config/mise/config.toml`, adoption остановится и предложит разрешить конфликт; проверьте `mise dot status`, выберите версию файла через `mise dot pull`, затем повторите `mise bootstrap`.

```sh
mise config ls
mise bootstrap plan
mise dot status
exec zsh
```

После добавления пользователя в группу `docker` нужен новый вход в систему. OrbStack на Mac может потребовать первого запуска приложения. Профили Mac и серверов пока не проверены на реальных машинах.

## 3. Отдельный root shell на Linux

Файлы root поставляются в репозитории, но не применяются основным bootstrap. После успешного пользовательского bootstrap запустите от обычного пользователя:

```sh
bash "$HOME/.config/mise/root/install.sh"
```

Скрипт ставит семь CLI в системный каталог, копирует отдельный root config и подключает его к `/root/.zshrc`. Повторный запуск безопасен. На Mac этот root-скрипт не применяется.

## Дальнейшие изменения

На машине, где меняете конфигурацию: `mise dot save ~/.config/mise && mise dot sync`. Путь обязателен: каталог помечен `autosave = false`, поэтому сохранение без пути его пропускает. На другой машине: `mise dot sync && mise dot pull && mise bootstrap`, затем откройте новый zsh. Режим `manual` не запускает фоновую синхронизацию или установку. Локальный список профилей меняйте в `~/.config/mise/miserc.local.toml`; эти данные не публикуются.
