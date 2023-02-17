#!/usr/bin/env bash
set -euo pipefail

scriptDir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$scriptDir"

# 根据last_build_version文件和SERVICE_IMAGE_VERSION环境变量设置服务镜像版本
if [ -f "${scriptDir}/last_build_version" ]; then
  service_image_version="$(head -n 1 last_build_version)"
fi
if [ "${SERVICE_IMAGE_VERSION:+exists}" ]; then
  service_image_version="$SERVICE_IMAGE_VERSION"
fi
source "${scriptDir}/config.sh"

# 创建文件夹
mkdir -p ~/log/ZJBrainSciencePlatform/{app,mysql}
mkdir -p ~/log/ZJBrainSciencePlatformAlgorithm/app
mkdir -p ~/data/ZJBrainSciencePlatform/file
mkdir -p ~/mysql/ZJBrainSciencePlatform/data

# 设置DockerCompose启动参数
export COMPOSE_PROJECT_NAME="$COMPOSE_PROJECT_NAME"
export PLATFORM_IMAGE_TAG="$platform_image_tag"
export DATABASE_IMAGE_TAG="$database_image_tag"
export CACHE_IMAGE_TAG="$cache_image_tag"
export ALGORITHM_IMAGE_TAG="$algorithm_image_tag"

docker compose \
  --file "${scriptDir}/docker-compose.yaml" \
  "$@"
