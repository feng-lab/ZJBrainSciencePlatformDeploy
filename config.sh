docker_username='zjlabbrainscience'
docker_token='dckr_pat_2PDLJLgitGJ6zztpsVtGVgGCz3s'
image_repo_prefix='zj-brain-science-platform'
compose_project_name='zj-brain-science-platform'

platform_replicas='1'
algorithm_replicas='1'

python_version='3.11'
poetry_version='1.3.2'
poetry_image_version="20230216"
pip_index_url='https://pypi.tuna.tsinghua.edu.cn/simple'

# 以下是生成的配置
service_image_version="${service_image_version:-$(date +%Y%m%d-%H%M%S)}"

poetry_image_tag="${docker_username}/${image_repo_prefix}-poetry:${poetry_image_version}"
platform_image_tag="${docker_username}/${image_repo_prefix}-platform:${service_image_version}"
database_image_tag="${docker_username}/${image_repo_prefix}-database:${service_image_version}"
cache_image_tag="redis:7.0"
algorithm_image_tag="${docker_username}/${image_repo_prefix}-algorithm:${service_image_version}"
