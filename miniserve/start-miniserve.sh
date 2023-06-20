#!/usr/bin/env bash
set -euo pipefail

sharePath=/zjbs-data/share
uid="$(id -u zjshare)"
gid="$(id -g zjshare)"
port=2000

docker stop miniserve
docker rm miniserve

docker run \
  --volume "${sharePath}:/data" \
  --publish "${port}:8080" \
  --user "${uid}:${gid}" \
  --name miniserve \
  --restart always \
  --detach \
  svenstaro/miniserve:alpine \
  --hidden \
  --upload-files \
  --mkdir \
  --enable-tar-gz \
  --dirs-first \
  --title zjbs-data \
  --show-symlink-info \
  --show-wget-footer \
  --header 'Access-Control-Allow-Origin: *' \
  /data
