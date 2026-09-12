# 备份边界

## A. GitHub 可以恢复的数据

- `server-bootstrap` 的脚本、说明和非敏感示例配置
- Quiz King 的源代码、Dockerfile、Compose 文件和数据库迁移脚本
- `.gitignore`、目录约定和健康检查脚本

## B. 必须额外备份的数据

- `/home/ubuntu/wangqi/data/quiz-king` 中的生产数据库、上传文件和运行状态
- 数据库原生导出文件
- `/home/ubuntu/wangqi/backups` 中经过校验的迁移包
- `/home/ubuntu/wangqi/data/proxy/config.yaml`，应使用加密存储

## C. 可以重新下载或重新生成的数据

- Docker 镜像和 Compose 依赖
- Codex CLI 安装包
- Mihomo 镜像
- 缓存、临时构建产物和可重新生成的实验输出

## D. 机密数据

- Clash 订阅 URL、节点凭据和配置
- `.env`、数据库密码、API Token
- SSH 私钥和云厂商凭据
- Codex/ChatGPT 登录认证文件

这些内容不进入 GitHub，也不由脚本自动读取、复制或上传。

## E. 不应该备份的数据

- `/tmp` 和个人 `tmp` 临时文件
- Docker 缓存和可重新拉取的镜像层
- 系统日志、系统包缓存和云厂商代理运行文件
- 其他用户或家人的目录、项目、容器、volume 和配置
