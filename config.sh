docker_username='zjlabbrainscience'
docker_token='dckr_pat_2PDLJLgitGJ6zztpsVtGVgGCz3s'
poetry_image_version="20230216"
image_repo_prefix='zj-brain-science-platform'

COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-zj-brain-science-platform}"
PYTHON_VERSION="${PYTHON_VERSION:-3.11}"
POETRY_VERSION="${POETRY_VERSION:-1.3.2}"
PIP_INDEX_URL="${PIP_INDEX_URL:-https://pypi.tuna.tsinghua.edu.cn/simple}"

# 生成的配置
service_image_version="${service_image_version:-$(date +%Y%m%d-%H%M%S)}"

poetry_image_tag="${docker_username}/${image_repo_prefix}-poetry:${poetry_image_version}"
platform_image_tag="${docker_username}/${image_repo_prefix}-platform:${service_image_version}"
database_image_tag="${docker_username}/${image_repo_prefix}-database:${service_image_version}"
cache_image_tag="redis:7.0"
algorithm_image_tag="${docker_username}/${image_repo_prefix}-algorithm:${service_image_version}"
