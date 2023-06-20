#!/usr/bin/env bash
set -euo pipefail

# 配置
dataset=zjbs-data
snapshotCount=14

# 创建新快照
snapshotName="$(date +'%Y%m%d-%H%M%S')"
zfs snapshot "${dataset}@${snapshotName}"

# 删除旧快照
for snapshotToDelete in $(zfs list -H -t snapshot -o name -S creation "$dataset" | tail --lines "+$((snapshotCount + 1))"); do
  zfs destroy -v "$snapshotToDelete"
done
