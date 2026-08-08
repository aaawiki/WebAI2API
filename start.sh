# 创建工作目录
mkdir -p ~/webai2api/data && cd ~@command:webai2api

# 拉取镜像
docker pull ghcr.io/aaawiki/webai-2api:latest

# 运行
docker run -d --name webai-2api \
  -p 3000:3000 \
  -v "$(pwd)/data:/app/data" \
  --shm-size=2gb \
  --restart unless-stopped \
  ghcr.io/aaawiki/webai-2api:latest
