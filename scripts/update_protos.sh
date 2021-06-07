#!/usr/bin/env sh

cd ..
git subtree pull --prefix=protos --squash git@github.modzy.engineering:modzy-platform/protobuf-storage.git master
cd -
