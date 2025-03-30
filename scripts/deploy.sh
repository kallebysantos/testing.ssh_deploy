#!/bin/bash
set -e

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
PROJECT_ROOT=$SCRIPTPATH/../

export $(grep -v '^#' "$PROJECT_ROOT/.env" | xargs)

IMAGE_NAME=${1:-"web"}
# Aqui vc mete o tipo de processador: ARM, AMD64 ...
TARGET_PLATFORM=${2:-"linux/amd64"}
BUILDER_FILE=${3:-"Dockerfile.$IMAGE_NAME"}

WORKING_DIR=$PROJECT_ROOT/src

echo "Generating image '$IMAGE_REPO/$IMAGE_NAME' for '$TARGET_PLATFORM'"

cd "$WORKING_DIR"

docker buildx build --load \
  --platform "$TARGET_PLATFORM" \
  -t "$IMAGE_REPO/$IMAGE_NAME:latest" \
  -f "build/$BUILDER_FILE" .

echo "Generating artifacts for image '$IMAGE_REPO/$IMAGE_NAME'"

TEMP_DIRNAME=$(mktemp -d)
TARBALL_FILENAME="$IMAGE_NAME.tar"
TARBALL_FILEPATH="$TEMP_DIRNAME/$TARBALL_FILENAME"

docker save -o "$TARBALL_FILEPATH" "$IMAGE_REPO/$IMAGE_NAME:latest"
echo "Artifact saved at '$TARBALL_FILEPATH'"

echo "Copying image to remote '$SSH_HOST'"
scp "$TARBALL_FILEPATH" "$SSH_USER@$SSH_HOST:~/$TARBALL_FILENAME"

echo "Cleaning local artifacts"
rm -R "$TEMP_DIRNAME"

echo "Upgrading remote containers"
ssh "$SSH_USER@$SSH_HOST" bash \
  -c "cd ~/; docker load -i $TARBALL_FILENAME &&
  cd app && docker compose up -d --remove-orphans &&
  docker image prune -f"

cd "$PROJECT_ROOT"
