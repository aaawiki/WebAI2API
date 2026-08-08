#!/usr/bin/env bash
#
# WebAI2API 服务器一键启动脚本
# 镜像: ghcr.io/aaawiki/webai-2api:latest
#
# 用法:
#   ./start-server.sh            # 创建目录、拉取镜像、启动容器
#   ./start-server.sh pull       # 仅拉取最新镜像
#   ./start-server.sh restart    # 重启容器
#   ./start-server.sh stop       # 停止并删除容器
#   ./start-server.sh logs       # 跟踪查看容器日志
#   ./start-server.sh status     # 查看容器状态
#
# 环境变量 (可选):
#   PORT         对外暴露端口，默认 3000
#   DATA_DIR     数据目录，默认 ./data
#   SHM_SIZE     共享内存大小，默认 2gb
#   IMAGE        镜像地址，默认 ghcr.io/aaawiki/webai-2api:latest
#   GHCR_TOKEN   若镜像为私有，传入 GitHub PAT (需 read:packages) 自动登录
#
set -euo pipefail

IMAGE="${IMAGE:-ghcr.io/aaawiki/webai-2api:latest}"
CONTAINER_NAME="webai-2api"
PORT="${PORT:-3000}"
DATA_DIR="${DATA_DIR:-$(pwd)/data}"
SHM_SIZE="${SHM_SIZE:-2gb}"

# 若提供了 GHCR_TOKEN，先登录 (私有镜像需要)
if [ -n "${GHCR_TOKEN:-}" ]; then
    echo "==> 登录 GitHub Container Registry"
    echo "${GHCR_TOKEN}" | docker login ghcr.io -u aaawiki --password-stdin
fi

case "${1:-start}" in
    pull)
        echo "==> 拉取镜像: ${IMAGE}"
        docker pull "${IMAGE}"
        ;;
    stop)
        echo "==> 停止并删除容器: ${CONTAINER_NAME}"
        docker rm -f "${CONTAINER_NAME}" 2>/dev/null || true
        ;;
    restart)
        echo "==> 重启容器: ${CONTAINER_NAME}"
        docker restart "${CONTAINER_NAME}"
        ;;
    logs)
        docker logs -f "${CONTAINER_NAME}"
        ;;
    status)
        docker ps -f "name=${CONTAINER_NAME}"
        ;;
    start)
        # 1. 创建工作目录
        echo "==> 创建工作目录: ${DATA_DIR}"
        mkdir -p "${DATA_DIR}"

        # 2. 拉取镜像
        echo "==> 拉取镜像: ${IMAGE}"
        docker pull "${IMAGE}"

        # 3. 若已存在同名容器则先移除，避免冲突
        if docker ps -a -q -f "name=${CONTAINER_NAME}" | grep -q .; then
            echo "==> 发现已存在容器，先移除: ${CONTAINER_NAME}"
            docker rm -f "${CONTAINER_NAME}"
        fi

        # 4. 运行容器
        echo "==> 启动容器: ${CONTAINER_NAME}"
        docker run -d \
            --name "${CONTAINER_NAME}" \
            -p "${PORT}:3000" \
            -v "${DATA_DIR}:/app/data" \
            --shm-size="${SHM_SIZE}" \
            --restart unless-stopped \
            "${IMAGE}"

        echo ""
        echo "✅ 启动完成！"
        echo "   WebUI / API 地址: http://localhost:${PORT}"
        echo "   数据目录: ${DATA_DIR}"
        echo "   查看日志: ./start-server.sh logs"
        ;;
    *)
        echo "未知命令: $1"
        echo "可用命令: start | pull | restart | stop | logs | status"
        exit 1
        ;;
esac
