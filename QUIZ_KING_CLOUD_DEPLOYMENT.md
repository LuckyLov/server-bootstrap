# Quiz King 云端测试部署

本文描述 Quiz King 的最小云端测试环境。当前采用 **Nginx + Certbot**，不切换现有 Caddy。Caddy 未来可以另行评估，但不属于本阶段部署链路。

## 已核验的应用依赖

以下内容来自当前 `quiz-king` 开发分支的仓库文件：

- Ubuntu Server 24.04 x86_64。
- Node.js 22 或更高版本；当前服务器已有 Node.js `v22.23.2`。
- Corepack；当前服务器已有 Corepack `0.34.6`。
- pnpm `11.19.0`，由根目录 `package.json` 的 `packageManager` 固定。
- 根目录执行 `pnpm install --frozen-lockfile`，再执行 `pnpm build`。
- 生产服务使用 Fastify、Socket.IO 和 `better-sqlite3`；SQLite 数据必须放在 `data/quiz-king`，不放进 Git 仓库。
- 代码质量与回归检查：`pnpm typecheck`、`pnpm test`。
- 完整浏览器 E2E 不是首轮云端启动的必需项；只有需要在服务器执行时，才额外运行 `pnpm e2e:install`，它会下载浏览器，体积较大。

`better-sqlite3` 是原生 Node 模块。若 pnpm 安装阶段没有可用的预编译包，Ubuntu 可能需要系统级编译工具（通常是 `build-essential`、`python3` 和相关 libc 开发文件）。应以实际安装日志为依据按需补装，不在首轮无条件安装大型依赖。

## 云端测试的系统依赖清单

清单位于 `config/quiz-king-cloud-packages.txt`，当前只列出：

```text
nginx
certbot
npm
pnpm
```

这份清单与通用 `config/base-packages.txt` 分开。原因是 Nginx、Certbot 会占用或管理共享系统的公网监听、配置和证书续期，不能被通用 `bootstrap.sh` 无条件自动安装。

如果采用 Certbot 的 Nginx 插件，才按实际证书方案额外评估 `python3-certbot-nginx`；当前清单不预装该插件。`npm` 用于 Node.js 工具链，`pnpm` 应通过 Corepack 固定为仓库要求的 `11.19.0`，不应依赖系统软件源中的未知旧版本。公网 IPv4 证书的申请参数和 Certbot 版本必须沿用已经复审的部署方案，不能把普通域名证书命令直接套用到 IP 地址上。

## 运行边界

生产 Node 进程必须只监听回环地址：

```text
127.0.0.1:3000
```

公网访问路径为：

```text
浏览器 --HTTPS--> Nginx --反向代理--> 127.0.0.1:3000
```

Nginx 需要显式转发 `Upgrade`、`Connection` 和 `X-Forwarded-*` 头，以支持 Socket.IO/WebSocket 和真实请求协议识别。不要开放 Node 的 3000 端口。证书私钥和 Certbot 状态按本项目约定放在 `/home/ubuntu/wangqi/data/quiz-king/certbot`，不能进入 GitHub。

当前服务器的 Caddy 已运行并占用公网 80 端口。因此 Nginx 安装、Caddy 停用、Nginx 监听接管、443/防火墙调整都必须先检查现有站点和监听者，再单独确认；不能直接执行。

## 本项目路径

| 内容 | 路径 |
|---|---|
| Git 仓库 | `/home/ubuntu/wangqi/repos/quiz-king` |
| 独立运行目录（如需要） | `/home/ubuntu/wangqi/apps/quiz-king` |
| SQLite 和运行数据 | `/home/ubuntu/wangqi/data/quiz-king` |
| 机密环境文件 | `/home/ubuntu/wangqi/data/quiz-king/quiz-king.env` |
| Certbot 状态和证书私钥 | `/home/ubuntu/wangqi/data/quiz-king/certbot` |
| ACME webroot | `/home/ubuntu/wangqi/data/quiz-king/acme-webroot` |
| 数据库和迁移备份 | `/home/ubuntu/wangqi/backups/quiz-king` |
| 应用日志 | `/home/ubuntu/wangqi/logs/quiz-king` |

仓库中的 `config/quiz-king.env.example`、`config/quiz-king.service.example` 和 `config/quiz-king.nginx.example` 仅是非敏感模板。真实 `.env`、证书、私钥、数据库和实际 Nginx 配置不得提交 GitHub。

注意：当前应用的自动备份默认路径与数据库目录相关。正式测试前应核对应用配置，确保导出文件最终落在 `/home/ubuntu/wangqi/backups/quiz-king`，不要因为默认值把备份留在仓库或系统目录中。

## 推荐执行顺序

### 1. 只读检查

先确认 Node、Corepack、pnpm、Nginx/现有 Caddy 状态、80/443/3000 端口、当前反向代理配置和证书方案。不要读取或复制家人的项目数据；对共享服务只检查状态、监听端口和与本项目相关的路由。

当前已知状态：Node 和 Corepack 已有，pnpm 尚未发现；Caddy 已启用并运行，Nginx 和 Certbot 未安装；公网 80 已被 Caddy 使用。

### 2. 准备 pnpm 和目录

```bash
corepack enable
corepack install --global pnpm@11.19.0
mkdir -p /home/ubuntu/wangqi/data/quiz-king \
  /home/ubuntu/wangqi/data/quiz-king/certbot \
  /home/ubuntu/wangqi/data/quiz-king/acme-webroot \
  /home/ubuntu/wangqi/backups/quiz-king \
  /home/ubuntu/wangqi/logs/quiz-king
chmod 700 /home/ubuntu/wangqi/data/quiz-king
```

随后在仓库执行：

```bash
cd /home/ubuntu/wangqi/repos/quiz-king
pnpm install --frozen-lockfile
pnpm typecheck
pnpm test
pnpm build
```

### 3. 准备真实环境文件

复制 `config/quiz-king.env.example` 到
`/home/ubuntu/wangqi/data/quiz-king/quiz-king.env`，由本人填写强随机的 `ADMIN_PIN`、真实 HTTPS 公网地址和其他秘密值。环境文件权限设为 `600`，不进入 Git。

### 4. 安装 Nginx/Certbot（需要单独确认）

安装前先报告：将安装哪些包、当前 80/443 的占用者、是否需要停用或迁移 Caddy、是否影响家人现有站点、回滚方式是什么。不得在未知现有配置的情况下直接安装并启用 Nginx。

安装包来源和版本应先核验。尤其是无域名、固定公网 IPv4 的场景，不能默认使用普通域名证书流程；应使用已经复审的公网 IP short-lived certificate 方案，并把 Certbot 的配置、工作目录、日志目录和证书目录限制在 `wangqi` 工作区。

### 5. 注册 systemd（需要单独确认）

`config/quiz-king.service.example` 是待审核模板。复制到 `/etc/systemd/system/quiz-king.service`、执行 `systemctl daemon-reload` 和启停服务都会修改系统级服务管理，并可能影响共享服务器；未得到确认前不执行。

服务应使用 `ubuntu` 用户、仓库工作目录和工作区内的环境文件，Node 仍绑定 `127.0.0.1`。日志通过服务配置写入 `/home/ubuntu/wangqi/logs/quiz-king`。

### 6. 配置 Nginx 和证书（需要单独确认）

`config/quiz-king.nginx.example` 是配置片段模板，不是当前生效配置。实际配置前必须把域名/IP、证书路径和现有站点冲突检查清楚；不要覆盖整个 `/etc/nginx/nginx.conf`，不要覆盖家人的 server block。

修改后按顺序执行配置校验、reload、证书健康检查和应用健康检查。证书续期必须使用只作用于 Quiz King 的 reload hook，不能重启或改动其他服务。

### 7. 验证

先在服务器本机检查 `http://127.0.0.1:3000/api/health`，再通过 HTTPS 公网地址运行：

```bash
pnpm cloud:doctor -- --public-url https://quiz.example.com
pnpm classroom:public-smoke -- --base-url https://quiz.example.com
```

首轮通过后再做并发/soak 测试。测试期间数据库、备份和日志仍必须留在 `wangqi` 工作区内。

## 回滚边界

- pnpm 和项目依赖安装：删除个人工作区中的 pnpm store 或重新构建即可，不删除其他 Docker 资源。
- systemd：停用并删除本项目自己的 `quiz-king.service` 前，必须确认服务名称和影响范围。
- Nginx：只回滚本次新增的 Quiz King 配置片段，不覆盖或删除其他站点配置。
- Caddy：在 Nginx 接管前必须记录其当前状态；不得为切换而删除 Caddy 配置或服务。若继续使用家人站点，应采用不影响既有监听的迁移方案。
- 不执行 `docker system prune`、`docker volume prune`、`docker network prune`，也不删除家人的服务、容器、volume 或数据。
