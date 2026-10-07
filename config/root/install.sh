#!/usr/bin/env bash
# One-time/idempotent Linux root shell setup; run as the ordinary user.
set -euo pipefail

if [[ $(uname -s) != Linux || $(id -u) -eq 0 ]]; then
  echo 'Run this on Linux as the ordinary user with sudo access.' >&2
  exit 1
fi

config_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
mise_bin=$(command -v mise)

# mise publishes binary releases into /usr/local/share/mise/installs with sudo.
mise install --system eza@latest bat@latest dust@latest duf@latest btop@latest ripgrep@latest fd@latest

backup_once() {
  if sudo test -e "$1" && ! sudo test -e "$1.pre-mise"; then
    sudo cp -p "$1" "$1.pre-mise"
  fi
}

backup_once /usr/local/bin/mise
backup_once /root/.config/mise/config.toml
backup_once /root/.zshrc
backup_once /etc/julesimf-shell/modern-root.zsh
backup_once /etc/julesimf-shell/modern-option-completion.zsh
backup_once /etc/julesimf-shell/zshrc-snippet.zsh

sudo install -D -m 0755 "$mise_bin" /usr/local/bin/mise
sudo install -D -m 0644 "$config_dir/root/config.toml" /root/.config/mise/config.toml
sudo install -D -m 0644 "$config_dir/root/modern-root.zsh" /etc/julesimf-shell/modern-root.zsh
sudo install -D -m 0644 "$config_dir/conf.d/modern/shell/modern-option-completion.zsh" /etc/julesimf-shell/modern-option-completion.zsh
sudo install -D -m 0644 "$config_dir/root/zshrc-snippet.zsh" /etc/julesimf-shell/zshrc-snippet.zsh
sudo chmod 700 /root/.config/mise

sudo touch /root/.zshrc
if ! sudo grep -Fq '# >>> julesimf-mise-root >>>' /root/.zshrc &&
   ! sudo grep -Fqx '[[ -r /etc/julesimf-shell/zshrc-snippet.zsh ]] && source /etc/julesimf-shell/zshrc-snippet.zsh' /root/.zshrc; then
  printf '\n%s\n' '[[ -r /etc/julesimf-shell/zshrc-snippet.zsh ]] && source /etc/julesimf-shell/zshrc-snippet.zsh' |
    sudo tee -a /root/.zshrc >/dev/null
fi
sudo chmod 600 /root/.zshrc

echo 'Root zsh uses the system mise installation and separate config.'
