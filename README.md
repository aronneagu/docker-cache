s repository is used as a testing bench for checking how docker cache actually works

Requirements:
Docker version (client & server): 20.10


Reproduce steps:
# Cleanup
docker system prune -af
docker buildx prune -a --force

Build using classic builder
docker build -f Dockerfile -t docker-cache:classic .

#NOTES
1. If /var/lib/docker is removed, then the docker daemon needs to be restarted to create the base directory structure
rm -rf /var/lib/docker && systemctl restart docker
2. IDs
There are at least 4 different IDs
Image ID
Layer ID
Cache ID
Push ID?
Pull ID

# FINDINGS
1. docker images -> IMAGE ID matchs
  /var/lib/docker/image/overlay2/imagedb/content/sha256 (json file)
  /var/lib/docker/image/overlay2/imagedb/metadata/sha256 (directory)
2. docker inspect IMAGE_ID | jq ".[].RootFS.Layers[]" = cat /var/lib/docker/image/overlay2/imagedb/content/sha256/IMAGE_ID | jq ".rootfs.diff_ids[]"
3. The number of layers from 2. is the same as "docker history IMAGE_ID", where SIZE!=0, plus 1. The additional layer is the sum of all layers that have SIZE=0 collapsed into 1 layer
4. The IMAGE_ID used in FROM clause is missing
  /var/lib/docker/image/overlay2/imagedb/metadata/sha256
5. Each layer has a corresponding directory in /var/lib/docker/overlay2 [1]
6. PULL_ID same as /var/lib/docker/image/overlay2/distribution/diffid-by-digest/sha256
7. Contents of /var/lib/docker/image/overlay2/distribution/diffid-by-digest/sha256/PULL_ID is the same as LAYER_ID
8. Each layer is stored as a directory in /var/lib/docker/overlay2
9. IMAGE_ID does not match directory name in /var/lib/docker/overlay2 [1]
10. /var/lib/docker/overlay2/l -> contains shortened layer identifiers as symbolic links


# REFERENCES
[1] https://dker.ru/docs/docker-engine/user-guide/docker-storage-drivers/overlayfs-storage-in-practice/
