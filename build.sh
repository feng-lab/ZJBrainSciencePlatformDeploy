#!/usr/bin/env bash
set -euo pipefail

scriptDir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$scriptDir"
source "${scriptDir}/config.sh"

set -x

# 构建镜像
docker build \
  --file "${scriptDir}/poetry.Dockerfile" \
  --tag "$poetry_image_tag" \
  --build-arg "PYTHON_VERSION=${python_version}" \
  --build-arg "POETRY_VERSION=${poetry_version}" \
  --build-arg "PIP_INDEX_URL=-i ${pip_index_url}" \
  "$scriptDir"

docker build \
  --file "${scriptDir}/platform.Dockerfile" \
  --tag "${platform_image_tag}" \
  --build-arg "POETRY_IMAGE_TAG=${poetry_image_tag}" \
  "$scriptDir"

docker build \
  --file "${scriptDir}/database.Dockerfile" \
  --tag "$database_image_tag" \
  "$scriptDir"

docker build \
  --file "${scriptDir}/algorithm.Dockerfile" \
  --tag "$algorithm_image_tag" \
  --build-arg "POETRY_IMAGE_TAG=${poetry_image_tag}" \
  "$scriptDir"

# 推送镜像到DockerHub
docker login --username "$docker_username" --password "$docker_token"
docker push "$poetry_image_tag"
docker push "$platform_image_tag"
docker push "$database_image_tag"
docker push "$algorithm_image_tag"

# 写入构建成功的版本号
echo "$service_image_version" >"${scriptDir}/last_build_version"
