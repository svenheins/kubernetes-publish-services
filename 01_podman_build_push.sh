#!/usr/bin/bash

## pull the image to podman (don't use the default tmp-directory, this would go to the root / directory)
#TMPDIR=/data/temp/podman podman pull docker-daemon:example-image:v1

source .env

podman build -t $IMAGE_NAME:$VERSION $APP_PATH

podman tag $IMAGE_NAME:$VERSION $REGISTRY/$IMAGE_NAME:$VERSION

echo $NO_PROXY | grep $REGISTRY -q || echo "Registry not in NO_PROXY, make sure your env is properly set up"
echo $no_proxy | grep $REGISTRY -q || echo "Registry not in no_proxy, make sure your env is properly set up"

if [[ `curl -k -s -o /dev/null -w '%{http_code}' https://$REGISTRY/$REGISTRY_VERSION/_catalog` != 200 ]]; then
    echo "ERROR: Registry cannot be reached"
    exit
fi

podman push $REGISTRY/$IMAGE_NAME:$VERSION

curl -sk https://$REGISTRY/$REGISTRY_VERSION/$IMAGE_NAME/tags/list | grep --color $VERSION