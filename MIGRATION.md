# 迁移流程

## 1. 旧服务器准备

确认工作区为 `/home/ubuntu/wangqi`，停止个人服务前先记录 Compose 项目、容器、网络和 volume。不要使用 `docker system prune`、`docker volume prune` 或 `docker network prune`。

确认 `server-bootstrap` 和 Quiz King 代码仓库没有未提交的重要代码；敏感配置不进入 Git。

## 2. 数据备份

将 `/home/ubuntu/wangqi/data` 中不能由 Git 恢复的数据导出到 `/home/ubuntu/wangqi/backups`，并把备份复制到独立的安全位置。数据库应使用应用或数据库原生导出，不直接依赖正在运行的数据库文件。

备份 `/home/ubuntu/wangqi/data/proxy/config.yaml` 时使用加密存储，不能提交到 GitHub。

## 3. GitHub 同步

提交并推送 `server-bootstrap` 和 Quiz King 代码仓库。推送前检查 `.env`、私钥、Token、Codex 登录目录、数据库和大型数据集没有被跟踪。

## 4. 新服务器初始化

在全新 Ubuntu 上：创建 `/home/ubuntu/wangqi`，clone `server-bootstrap`，执行 `bootstrap.sh`，重新登录使 docker 组生效，然后执行 `verify.sh`。如果服务器网络受限，先恢复服务器侧代理或提供临时代理环境变量。

## 5. 数据恢复

将经过校验的备份恢复到 `/home/ubuntu/wangqi/data` 和 `/home/ubuntu/wangqi/backups`。代理配置恢复到 `/home/ubuntu/wangqi/data/proxy/config.yaml`，权限设置为 `600`。

## 6. 服务恢复

clone Quiz King 到 `/home/ubuntu/wangqi/repos/quiz-king`，使用其 Compose 文件启动；项目名、容器、网络和 volume 使用 `wangqi-` 前缀，数据挂载到 `/home/ubuntu/wangqi/data/quiz-king`。

如需代理，先用 `config/mihomo-compose.yaml` 启动 `wangqi-proxy`，再设置本机代理环境变量。不要暴露代理、Codex App Server、数据库或 Jupyter 端口。

## 7. 验证

依次验证目录所有者和权限、Git、Docker、Compose、Codex CLI、代理连通性、Quiz King 健康检查、数据库读写和备份可恢复性，最后进行应用级并发测试。
