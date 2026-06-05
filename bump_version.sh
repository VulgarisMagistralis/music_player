#!/bin/bash
PUBSPEC_FILE="pubspec.yaml"
VERSION_CODE=$(sed -n 's/.*+[[:space:]]*\([0-9]\+\).*/\1/p' $PUBSPEC_FILE |  tr -d '\n')
if [ -z "$VERSION_CODE" ]; then
  echo "Error: Could not find version code"
  exit 1
fi
NEW_VERSION=$((VERSION_CODE + 1))
sed -i "s|+$VERSION_CODE/+$NEW_VERSION/" $PUBSPEC_FILE
echo "Version bumped from $VERSION_CODE to $NEW_VERSION"
