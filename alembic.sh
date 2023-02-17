#!/usr/bin/env bash
set -euo pipefail

scriptDir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$scriptDir"
source "${scriptDir}/config.sh"

bash "${scriptDir}/deploy.sh" run --rm platform \
  alembic upgrade head
