#!/usr/bin/env bash
set -Eeuo pipefail

WANGQI_ROOT="/home/ubuntu/wangqi"
[[ $(id -un) == ubuntu ]] || { echo 'Run this script as ubuntu.' >&2; exit 1; }
[[ -r /etc/os-release ]] || { echo 'Missing /etc/os-release.' >&2; exit 1; }
. /etc/os-release
[[ ${ID:-} == ubuntu ]] || { echo "Only Ubuntu is supported; detected ${ID:-unknown}." >&2; exit 1; }
case "${VERSION_ID:-}" in 22.04|24.04|26.04) ;; *) echo "Unsupported Ubuntu version: ${VERSION_ID:-unknown}." >&2; exit 1 ;; esac

sudo apt-get update
sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl git rsync tmux htop gnupg

docker_key=/etc/apt/keyrings/docker.asc
docker_sources=/etc/apt/sources.list.d/docker.sources
docker_codename="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
sudo install -m 0755 -d /etc/apt/keyrings
key_tmp=$(mktemp)
repo_tmp=$(mktemp)
trap 'rm -f "${key_tmp}" "${repo_tmp}"' EXIT
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o "${key_tmp}"
sudo install -m 0644 "${key_tmp}" "${docker_key}"
printf '%s\n' \
  'Types: deb' \
  'URIs: https://download.docker.com/linux/ubuntu' \
  "Suites: ${docker_codename}" \
  'Components: stable' \
  "Architectures: $(dpkg --print-architecture)" \
  "Signed-By: ${docker_key}" > "${repo_tmp}"
if [[ -e ${docker_sources} ]]; then
  cmp -s "${repo_tmp}" "${docker_sources}" || { echo "Existing ${docker_sources} differs; refusing to overwrite." >&2; exit 1; }
else
  sudo install -m 0644 "${repo_tmp}" "${docker_sources}"
fi
sudo apt-get update
sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
getent group docker >/dev/null 2>&1 || sudo groupadd docker
id -nG ubuntu | tr ' ' '\n' | grep -qx docker || sudo usermod -aG docker ubuntu

sudo install -d -o ubuntu -g ubuntu -m 0700 "${WANGQI_ROOT}"
for dir in apps data backups repos server-bootstrap logs tmp; do
  sudo install -d -o ubuntu -g ubuntu -m 0700 "${WANGQI_ROOT}/${dir}"
done

export PATH="${HOME}/.local/bin:${PATH}"
if ! command -v codex >/dev/null 2>&1; then curl -fsSL https://chatgpt.com/codex/install.sh | sh; fi
grep -qxF 'export PATH=/home/ubuntu/.local/bin:$PATH' "${HOME}/.profile" 2>/dev/null || printf '%s\n' 'export PATH=/home/ubuntu/.local/bin:$PATH' >> "${HOME}/.profile"
printf 'Bootstrap completed. Re-login is required for the docker group to apply.\n'
