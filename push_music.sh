#!/system/bin/sh
# Copy all music files from user 0 to user 10 via MediaStore
SRC=/sdcard/Music
DEST_USER=10

for f in "$SRC"/*.mp3 "$SRC"/*.flac "$SRC"/*.wav "$SRC"/*.m4a; do
  [ -f "$f" ] || continue
  name=$(basename "$f")
  ext="${name##*.}"
  case "$ext" in
    mp3) mime=audio/mpeg ;;
    flac) mime=audio/flac ;;
    wav) mime=audio/wav ;;
    m4a) mime=audio/mp4 ;;
    *) continue ;;
  esac
  size=$(stat -c%s "$f" 2>/dev/null || echo 0)
  # Insert into MediaStore
  result=$(content insert --user $DEST_USER --uri content://media/external/audio/media \
    --bind _display_name:s:"$name" \
    --bind mime_type:s:"$mime" \
    --bind relative_path:s:Music/ \
    --bind _size:i:$size 2>&1)
  uri_id=$(content query --user $DEST_USER --uri content://media/external/audio/media \
    --projection _id:_display_name \
    --where "_display_name='$name'" 2>&1 | grep "_id=" | head -1 | sed 's/.*_id=//' | sed 's/,.*//')
  if [ -n "$uri_id" ]; then
    cat "$f" | content write --user $DEST_USER --uri content://media/external/audio/media/$uri_id 2>&1
    echo "Copied: $name (id=$uri_id)"
  fi
done
echo "Done"
SCRIPT
chmod +x /tmp/push_music_to_user10.sh
adb push /tmp/push_music_to_user10.sh /data/local/tmp/push_music.sh
/tmp/push_music_to_user10.sh: 1 file pushed, 0 skipped. 59.0 MB/s (1117 bytes in 0.000s)

# MediaStore file creation works through FUSE. Let me create a script to batch-copy all music files.
# $ adb push /home/cnek/Music/phone/. /sdcard/Music/
