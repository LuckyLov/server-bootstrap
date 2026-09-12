# Wangqi Server Bootstrap

这是 `/home/ubuntu/wangqi` 个人教学/科研节点的可重建配置仓库。

本仓库只保存环境说明、幂等脚本和非敏感示例配置，不保存真实密码、Token、GitHub CLI/Codex 登录文件、Clash 配置、SSH 私钥、数据库和实验数据。

## 全新 Ubuntu 快速开始

```bash
cd /home/ubuntu/wangqi/server-bootstrap
chmod +x bootstrap.sh verify.sh
./bootstrap.sh
./verify.sh
```

如果新服务器所在网络不能直接访问 OpenAI 或 Docker Hub，应先准备服务器侧代理，或在执行脚本时临时提供 `HTTP_PROXY`/`HTTPS_PROXY`。真实代理配置应恢复到 `/home/ubuntu/wangqi/data/proxy/config.yaml`，不能提交到 GitHub。

## 当前节点约定

- 个人工作区：`/home/ubuntu/wangqi`
- Git 仓库：`/home/ubuntu/wangqi/repos`
- 持久数据：`/home/ubuntu/wangqi/data`
- 备份：`/home/ubuntu/wangqi/backups`
- 当前代理容器：`wangqi-proxy`
- 代理配置：`/home/ubuntu/wangqi/data/proxy/config.yaml`，仅本机使用，权限应为 `600`
- Mihomo Compose 示例：`config/mihomo-compose.yaml`

脚本不会卸载冲突软件、删除 Docker 资源、执行 prune、修改 SSH、防火墙、Caddy 或其他用户环境。Docker 使用共享系统 daemon；个人容器、网络和 volume 必须使用 `wangqi-` 前缀。

基础 Ubuntu 软件包清单位于 `config/base-packages.txt`，`bootstrap.sh` 会自动读取并幂等安装。以后增加基础组件时，在该文件新增一行、提交并推送即可；不要把个人项目依赖直接安装到系统环境。

Quiz King 云端测试暂定使用 Nginx + Certbot 作为 HTTPS 反向代理。依赖、路径、systemd、Nginx 和证书配置模板见 `QUIZ_KING_CLOUD_DEPLOYMENT.md`、`config/quiz-king-cloud-packages.txt` 及 `config/quiz-king.*.example`。实际安装、systemd、Nginx、证书和防火墙配置都属于系统级变更，必须在检查共享服务并确认后执行。Caddy 仅保留为未来可选方案，本阶段不切换。

GitHub CLI (`gh`) 通过 Ubuntu 软件包安装，用于在需要认证的 GitHub 仓库上执行 Git 凭据配置。新服务器初始化后，由本人交互执行：

```bash
gh auth login
gh auth setup-git
```

认证文件和 Token 保留在用户目录中，不进入本仓库；脚本不会读取、复制、备份或上传它们。

Codex CLI 按 OpenAI 官方 Linux 独立安装器安装。脚本不会执行 ChatGPT/Codex 登录，也不会读取或复制认证文件；新服务器上需由本人手动运行 `codex` 完成登录。
