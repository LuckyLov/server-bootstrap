# 目录布局

根目录：`/home/ubuntu/wangqi`

| 目录 | 用途 |
|---|---|
| `apps/` | 实际运行的个人应用；例如 `apps/quiz-king` |
| `data/` | 不能仅靠 Git 恢复的持久数据；例如 `data/quiz-king` 和 `data/proxy` |
| `backups/` | 数据库导出、迁移包和配置备份；例如 `backups/quiz-king` |
| `repos/` | Git 仓库和开发项目；Quiz King 使用 `repos/quiz-king` |
| `server-bootstrap/` | 当前个人服务器如何从零重建的 Git 仓库 |
| `logs/` | 个人项目日志；例如 `logs/quiz-king` |
| `tmp/` | 可随时删除的临时文件、中间结果和下载文件 |

代码、持久数据、备份和机密配置分离。系统级目录只保存操作系统、Docker 和必要服务的系统配置；不把个人项目数据写入 `/srv`、`/opt`、`/root` 或其他用户目录。

Quiz King 的云端依赖与部署顺序记录在 `QUIZ_KING_CLOUD_DEPLOYMENT.md`；仓库中的环境、systemd、Nginx 和 Certbot 文件均为非敏感示例，不代表已经修改系统级配置。
