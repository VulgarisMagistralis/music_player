#!/bin/bash
PUBSPEC_FILE="pubspec.yaml"
OLD_NUM=$(grep '^version:' $PUBSPEC_FILE | grep -oP '(?<=\+)[[:digit:]]+')
if [ -z "$OLD_NUM" ]; then
  NEW_NUM=1
else
  NEW_NUM=$((OLD_NUM + 1))
fi
sed -i "/^version:/s/+\($OLD_NUM\)/+$NEW_NUM/" $PUBSPEC_FILE
echo "Version code updated to $NEW_NUM"
