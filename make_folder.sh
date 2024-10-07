# ограниченная папка на макоси получилась только через образ диска (спасите)
# bash make_folder.sh

IMAGE_SIZE=1g
IMAGE_PATH="/Users/kseniasaprykina/Downloads/op/op/disk_image.dmg"
VOLUME_NAME="MyDisk"
MOUNT_POINT="/Users/kseniasaprykina/Downloads/op/op/MyDisk"

hdiutil create -size "$IMAGE_SIZE" -fs HFS+ -volname "$VOLUME_NAME" "$IMAGE_PATH"

hdiutil attach "$IMAGE_PATH" -mountpoint "$MOUNT_POINT"

mkdir -p "$MOUNT_POINT/log"