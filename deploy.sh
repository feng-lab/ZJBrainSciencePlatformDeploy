#!/usr/bin/env bash
set -euo pipefail

scriptDir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$scriptDir"

source "${scriptDir}/compose.sh" convert

# 创建文件夹
mkdir -p ~/log/ZJBrainSciencePlatform/{app,mysql}
mkdir -p ~/log/ZJBrainSciencePlatformAlgorithm/app
mkdir -p ~/data/ZJBrainSciencePlatform/file
mkdir -p ~/mysql/ZJBrainSciencePlatform/data

docker stack \
  --orchestrator swarm \
  "$@"
