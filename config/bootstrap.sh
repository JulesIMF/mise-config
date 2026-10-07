#!/bin/sh
# Bootstrap a new Linux or macOS machine from the public mise configuration.
# curl -fsSL https://raw.githubusercontent.com/JulesIMF/mise-config/main/bootstrap.sh | sh
set -eu

case "${1:-}" in
  '') run_mode=apply ;;
  --dry-run) run_mode=dry-run ;;
  *) printf 'bootstrap: Поддерживается только аргумент --dry-run.\n' >&2; exit 1 ;;
esac
[ "$#" -le 1 ] || { printf 'bootstrap: Слишком много аргументов.\n' >&2; exit 1; }

https_repo='https://github.com/JulesIMF/mise-config.git'
ssh_repo='git@github.com:JulesIMF/mise-config.git'
repo=$https_repo
config_dir="$HOME/.config/mise"
profiles_file="$config_dir/miserc.local.toml"
history_file="$config_dir/config.local.toml"
work_file="$HOME/.config/julesimf-shell/work-local.zsh"

say() { printf '%s\n' "$*"; }
die() { printf 'bootstrap: %s\n' "$*" >&2; exit 1; }
has() { command -v "$1" >/dev/null 2>&1; }

if [ "$(id -u)" -eq 0 ]; then
  as_root() { "$@"; }
else
  as_root() { sudo "$@"; }
fi

case "$(uname -s)" in
  Linux) os=linux ;;
  Darwin) os=macos ;;
  *) die 'Поддерживаются Linux и macOS; для этой ОС нет проверенного установщика mise.' ;;
esac

case "$os" in
  linux)
    if has apt-get; then packages=apt
    elif has dnf; then packages=dnf
    elif has pacman; then packages=pacman
    elif has apk; then packages=apk
    else die 'Нужен apt-get, dnf, pacman или apk для первичной установки.'
    fi
    ;;
  macos) packages=macos ;;
esac

case "$packages" in
  apt)
    distro=$(. /etc/os-release 2>/dev/null; printf '%s' "${ID:-unknown}")
    ;;
  *) distro=other ;;
esac

if [ "$os" = macos ]; then
  default_profiles='personal,host,node'
elif [ "$distro" = ubuntu ] && { [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; }; then
  default_profiles='personal,host,ubuntu-desktop,node'
else
  default_profiles='personal,server'
fi

if [ "${MISE_BOOTSTRAP_PROFILES+x}" = x ]; then
  selected=$MISE_BOOTSTRAP_PROFILES
  [ -n "$selected" ] || die 'MISE_BOOTSTRAP_PROFILES задан, но пуст.'
elif [ -e "$profiles_file" ]; then
  selected=''
else
  [ -r /dev/tty ] || die 'Выберите профили через MISE_BOOTSTRAP_PROFILES=personal,server перед curl | sh.'
  say "Профили новой машины (через запятую), Enter = $default_profiles:"
  say 'Доступны: work, personal, host, server, container, ubuntu-desktop, docker-ubuntu, docker-macos, node, modern-extra, yandex-cloud, skotty.'
  IFS= read -r selected </dev/tty || die 'Не удалось прочитать выбор профилей.'
  [ -n "$selected" ] || selected=$default_profiles
fi

if [ -n "$selected" ]; then
  old_ifs=$IFS
  IFS=,
  # Deliberately split only the comma-separated profile list.
  set -- $selected
  IFS=$old_ifs
  [ "$#" -gt 0 ] || die 'Список профилей пуст.'
  toml_profiles=''
  role_count=0
  owner_count=0
  normalized_profiles=''
  for profile do
    profile=$(printf '%s' "$profile" | tr -d '[:space:]')
    case "$profile" in
      work|personal|host|server|container|ubuntu-desktop|docker-ubuntu|docker-macos|node|modern-extra|yandex-cloud|skotty) ;;
      *) die "Неизвестный профиль: $profile" ;;
    esac
    case "$profile" in host|server|container) role_count=$((role_count + 1));; esac
    case "$profile" in work|personal) owner_count=$((owner_count + 1));; esac
    case "$profile" in
      ubuntu-desktop|docker-ubuntu)
        [ "$distro" = ubuntu ] || die "$profile доступен только на Ubuntu." ;;
      docker-macos)
        [ "$os" = macos ] || die 'docker-macos доступен только на macOS.'
        [ "$(uname -m)" = arm64 ] || die 'Профиль docker-macos рассчитан на Apple Silicon.' ;;
    esac
    if [ -z "$toml_profiles" ]; then toml_profiles="\"$profile\""
    else toml_profiles="$toml_profiles, \"$profile\""
    fi
    normalized_profiles="$normalized_profiles,$profile"
  done
  [ "$role_count" -eq 1 ] || die 'Выберите ровно одну роль: host, server или container.'
  [ "$owner_count" -eq 1 ] || die 'Выберите work или personal.'
  case "$normalized_profiles," in
    *,container,*)
      case "$normalized_profiles," in *,docker-ubuntu,*|*,docker-macos,*) die 'Docker daemon не устанавливается в container.';; esac
      ;;
  esac
  say "Профили: $selected"
else
  say "Сохранённый выбор: $profiles_file"
fi

if [ "$run_mode" = dry-run ]; then
  say 'Dry run: установка пакетов, настройка shell и mise не выполнялись.'
  exit 0
fi

if [ "$os" = linux ]; then
  if [ "$(id -u)" -ne 0 ]; then has sudo || die 'Для системных пакетов нужен sudo.'; fi
  missing=''
  for cmd in git curl zsh bash; do has "$cmd" || missing="$missing $cmd"; done
  if [ -n "$missing" ]; then
    say "Устанавливаю первичные пакеты:$missing ca-certificates"
    case "$packages" in
      apt) as_root apt-get update; as_root apt-get install -y git curl ca-certificates zsh bash ;;
      dnf) as_root dnf install -y git curl ca-certificates zsh bash ;;
      pacman) as_root pacman -Sy --needed --noconfirm git curl ca-certificates zsh bash ;;
      apk) as_root apk add --no-cache git curl ca-certificates zsh bash ;;
    esac
  fi
else
  has curl || die 'На macOS нужен curl.'
  has git || die 'Установите Xcode Command Line Tools командой xcode-select --install и запустите скрипт снова.'
fi

has git && has curl && has zsh || die 'После установки отсутствуют git, curl или zsh.'
[ -x /bin/zsh ] || die 'Конфигурация ожидает /bin/zsh; установите zsh по этому пути.'

if ! has mise && [ ! -x "$HOME/.local/bin/mise" ]; then
  say 'Устанавливаю mise...'
  installer=$(mktemp) || die 'Не удалось создать временный файл.'
  trap 'rm -f "$installer"' EXIT HUP INT TERM
  curl -fsSL https://mise.run -o "$installer" || die 'Не удалось скачать установщик mise.'
  sh "$installer" || die 'Установщик mise завершился с ошибкой.'
  rm -f "$installer"
  trap - EXIT HUP INT TERM
fi
PATH="$HOME/.local/bin:$PATH"
export PATH
has mise || die 'mise не появился в ~/.local/bin или PATH.'

say "Проверяю доступ к $https_repo..."
git ls-remote "$https_repo" HEAD >/dev/null || die 'Публичный репозиторий GitHub недоступен.'
if has ssh && GIT_SSH_COMMAND='ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=5' \
    git ls-remote "$ssh_repo" HEAD >/dev/null 2>&1; then
  repo=$ssh_repo
  say 'SSH-ключ GitHub работает; для истории выбран SSH-адрес.'
else
  say 'SSH-ключ GitHub не найден; для чтения выбран HTTPS-адрес.'
fi

umask 077
mkdir -p "$config_dir"
if [ ! -e "$history_file" ]; then
  printf '[settings.history]\nsync = "manual"\n' >"$history_file"
fi
if [ ! -e "$profiles_file" ]; then
  [ -n "$toml_profiles" ] || die 'Нет выбранных профилей.'
  printf 'env = [%s]\n' "$toml_profiles" >"$profiles_file"
elif [ -n "$selected" ]; then
  say "Сохраняю существующий $profiles_file; выбор из команды его не перезаписывает."
fi

if [ -f "$HOME/.zshrc" ] && [ ! -e "$HOME/.zshrc.pre-mise-bootstrap" ]; then
  cp -p "$HOME/.zshrc" "$HOME/.zshrc.pre-mise-bootstrap"
fi

# mise can call chsh interactively. Set the configured login shell with sudo first,
# so the subsequent user bootstrap is idempotent even when stdin is a pipe.
current_shell=$(getent passwd "$(id -un)" 2>/dev/null | awk -F: '{print $7}')
if [ "$os" = macos ]; then
  current_shell=$(dscl . -read "/Users/$(id -un)" UserShell 2>/dev/null | awk '{print $2}')
fi
if [ "$current_shell" != /bin/zsh ]; then
  say "Меняю login shell пользователя $(id -un) на /bin/zsh (потребуется sudo)..."
  if [ "$os" = linux ] && has usermod; then
    as_root usermod -s /bin/zsh "$(id -un)"
  else
    as_root chsh -s /bin/zsh "$(id -un)"
  fi
fi

say 'Применяю конфигурацию mise...'
if [ "$distro" = ubuntu ]; then
  mise bootstrap --adopt "$repo" --update --yes
else
  mise bootstrap --adopt "$repo" --yes
fi

if grep -Eq '"work"' "$profiles_file"; then
  mkdir -p "$(dirname "$work_file")"
  if [ ! -e "$work_file" ]; then : >"$work_file"; chmod 600 "$work_file"; fi
fi

if [ "$os" = linux ] && [ "$(id -u)" -ne 0 ] && [ -f "$config_dir/root/install.sh" ]; then
  say 'Устанавливаю отдельный root shell и системные modern CLI...'
  bash "$config_dir/root/install.sh"
fi

say ''
say 'Готово. Пути и следующие действия:'
say "  Профили: $profiles_file"
say "  Режим синхронизации: $history_file"
say "  Инструкция: $config_dir/DEPLOY.md"
if [ -e "$work_file" ]; then say "  Локальный рабочий shell: $work_file"; fi
if [ -e "$HOME/.zshrc.pre-mise-bootstrap" ]; then say "  Старый zshrc: $HOME/.zshrc.pre-mise-bootstrap"; fi
say '  Проверьте mise bootstrap plan и mise dot status.'
say '  Выйдите и войдите снова: смена login shell и членство в группе docker вступят в силу.'
say '  Для будущих обновлений: mise dot sync && mise dot pull && mise bootstrap.'
if [ "$repo" = "$https_repo" ]; then
  say '  Для публикации изменений настройте GitHub HTTPS credentials или переключите origin на SSH.'
fi
