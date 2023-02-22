#!/usr/bin/env bash
set -euo pipefail

scriptDir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$scriptDir"

source "${scriptDir}/compose.sh" version

# 创建文件夹
mkdir -p ~/log/ZJBrainSciencePlatform/{app,mysql}
mkdir -p ~/log/ZJBrainSciencePlatformAlgorithm/app
mkdir -p ~/data/ZJBrainSciencePlatform/file
mkdir -p ~/mysql/ZJBrainSciencePlatform/data

# 检查DockerSwarm
if ! docker node ls; then
  echo 'Docker Swarm 没有初始化'
  exit 1
fi

args="${*:-deploy -c "${scriptDir}/docker-compose.yaml" platform}"
docker stack $args
