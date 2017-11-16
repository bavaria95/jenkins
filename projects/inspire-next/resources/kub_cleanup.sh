#!/bin/bash -x

sudo -i

echo "This will remove: "
echo "  - all stopped containers"
echo "  - all volumes not used by at least one container"
echo "  - all images without at least one container associated to them"
# available starting from 1.13
docker system prune -f

echo "Removing inspire-base images"
docker images -a | grep "inspire-base" | awk '{print $3}' | xargs -r docker rmi -f

echo "Removing untagged images"
docker images -a | grep '<none>' | awk '{print $3}' | xargs -r docker rmi

echo "Removing dangling images"
docker images --no-trunc -q -f dangling=true | xargs -r docker rmi

echo "Done"

exit 0

