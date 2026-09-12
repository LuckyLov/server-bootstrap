#!/usr/bin/env bash
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO="${ROOT}/server-bootstrap"
status=0
ok() { printf 'OK   %s\n' "$*"; }
warn() { printf 'WARN %s\n' "$*"; status=1; }

for dir in apps data backups repos server-bootstrap logs tmp; do
  [[ -d "${ROOT}/${dir}" ]] && ok "directory ${ROOT}/${dir}" || warn "missing directory ${ROOT}/${dir}"
done
[[ $(stat -c '%U' "${ROOT}" 2>/dev/null) == ubuntu ]] && ok 'workspace owner ubuntu' || warn 'workspace owner is not ubuntu'
[[ $(stat -c '%a' "${ROOT}" 2>/dev/null) == 700 ]] && ok 'workspace mode 700' || warn 'workspace mode is not 700'

for command_name in git gh curl rsync tmux; do
  command -v "${command_name}" >/dev/null 2>&1 && ok "${command_name} available" || warn "${command_name} missing"
done
command -v codex >/dev/null 2>&1 || [[ -x ${HOME}/.local/bin/codex ]] && ok 'codex available' || warn 'codex missing'
command -v docker >/dev/null 2>&1 && ok 'docker available' || warn 'docker missing'
docker info >/dev/null 2>&1 || sudo -n docker info >/dev/null 2>&1 && ok 'docker daemon reachable' || warn 'docker daemon is not reachable; re-login may be required'
docker compose version >/dev/null 2>&1 || sudo -n docker compose version >/dev/null 2>&1 && ok 'docker compose available' || warn 'docker compose missing'

if [[ -d ${REPO}/.git ]]; then
  ok 'server-bootstrap is a Git repository'
  sensitive=$(git -C "${REPO}" ls-files | grep -E '(^|/)(\.env($|\.)|.*\.(pem|key)$|credentials($|\.)|credential($|\.)|token($|\.)|tokens($|\.)|secret($|\.)|secrets($|\.)|auth\.jsonl?$|.*\.(sqlite|sqlite3|db|wal|shm|pid)$)' || true)
  [[ -z ${sensitive} ]] && ok 'no obvious sensitive files tracked' || warn "possible sensitive tracked files: ${sensitive}"
else
  warn 'server-bootstrap Git repository is missing'
fi
exit "${status}"
