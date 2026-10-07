# Развёртывание на новой машине

## Быстрый запуск

`bootstrap.sh` — POSIX `sh` скрипт для Linux и macOS. Запустите из bash или zsh:

```sh
curl -fsSL https://raw.githubusercontent.com/JulesIMF/mise-config/main/bootstrap.sh | sh
```

Скрипт читает публичный `https://github.com/JulesIMF/mise-config.git` без учётных данных. Если на машине уже работает GitHub SSH-ключ, он выберет SSH-адрес для последующей публикации изменений; иначе оставит HTTPS. Для публикации через HTTPS позже понадобится GitHub credential helper или переключение origin на SSH.

Скрипт предложит профили в терминале (поток `stdin` занят кодом скрипта), установит необходимые первичные пакеты, поставит mise, проверит доступ к репозиторию, создаст локальные файлы выбора профилей и ручной синхронизации, применит `mise bootstrap --adopt`, выставит `/bin/zsh` login shell через `sudo`, а на Linux затем запустит отдельный root setup. Пароль `sudo` вводите в терминале. При повторном запуске локальные файлы и копия старого `.zshrc` сохраняются.

Для запуска без интерактивного выбора передайте список профилей в окружении процесса `sh`:

```sh
curl -fsSL https://raw.githubusercontent.com/JulesIMF/mise-config/main/bootstrap.sh | MISE_BOOTSTRAP_PROFILES=work,server,docker-ubuntu sh
```

Для проверки выбора без изменений можно выполнить `sh bootstrap.sh --dry-run`. После завершения скрипт напечатает полные пути к `miserc.local.toml`, локальному рабочему файлу и инструкции. После смены login shell и добавления в группу Docker требуется новый вход.

На Ubuntu Git/curl при необходимости можно поставить вручную через `sudo apt-get update && sudo apt-get install -y git curl ca-certificates`. На Mac проверьте `git --version`; если macOS предлагает Command Line Tools, установите их. На Apple Silicon отдельная установка Homebrew для профилей `brew:`/`brew-cask:` не нужна: mise использует встроенный менеджер.

## 1. Установить mise и выбрать профили

```sh
curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
git ls-remote https://github.com/JulesIMF/mise-config.git HEAD

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
mise bootstrap --adopt https://github.com/JulesIMF/mise-config.git --update --dry-run
mise bootstrap --adopt https://github.com/JulesIMF/mise-config.git --update
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
