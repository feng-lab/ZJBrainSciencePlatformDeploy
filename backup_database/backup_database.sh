#! /usr/bin/env bash
set -euo pipefail

# 配置
backupDir=/data/ZJBrainSciencePlatformDatabaseBackups
backupCount=30
username=root
password=zjlab2022root
databases=(zj_brain_science_platform)
containerName=platform_database
containerBackupDir=/backup

# 创建备份文件夹
if [ ! -d "$backupDir" ]; then
  mkdir -p "$backupDir"
fi

# 获取数据库容器ID
containerId="$(docker ps --format '{{.ID}}|{{.Names}}' | grep -- "$containerName" | cut --delimiter '|' --fields 1)"
if [ -z "$containerId" ]; then
  echo >&2 "cannot get mysql container id"
  exit 1
fi

# 创建并压缩备份
backupBaseFileName="$(date +'%T%m%d-%H%M%S')"
backupCommand="mysqldump --user=${username} --password=${password} --result-file=${containerBackupDir}/${backupBaseFileName}.sql --databases ${databases[*]}"
docker exec "$containerId" sh -c "'$backupCommand'"
tar -C "$backupDir" -caf "${backupBaseFileName}.tar.xz" "${backupBaseFileName}.sql"
rm --verbose "${backupDir}/${backupBaseFileName}.sql"

# 删除超过数量上限的、最旧的备份
tailCount=$((backupCount + 1))
# shellcheck disable=SC2010
for fileToDelete in $(ls -1ctp "${backupDir}" | grep '.tar.xz' | grep -v '/' | tail -n +"$tailCount"); do
  rm --verbose "${backupDir}/${fileToDelete}"
done
