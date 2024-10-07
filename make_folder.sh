# ограниченная папка на макоси получилась только через образ диска (спасите)
# bash make_folder.sh

IMAGE_SIZE=1g
IMAGE_NAME="disk_image.dmg"  
WORKING_DIR="$(pwd)"  

mkdir -p "$WORKING_DIR"

IMAGE_PATH="$WORKING_DIR/$IMAGE_NAME"

VOLUME_NAME="MyDisk"
MOUNT_POINT="$WORKING_DIR/MyDisk" 

hdiutil create -size "$IMAGE_SIZE" -fs HFS+ -volname "$VOLUME_NAME" "$IMAGE_PATH"

hdiutil attach "$IMAGE_PATH" -mountpoint "$MOUNT_POINT"

mkdir -p "$MOUNT_POINT/log"