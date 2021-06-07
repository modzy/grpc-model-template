#!/usr/bin/env sh

PACKAGE_ROOT="$(pwd)/.."

# TODO: try to get this to have the appropriate paths set with a sed command after the poetry run command. e.g. grpc_model.src.auto_generated.
poetry run python -m grpc_tools.protoc -I"${PACKAGE_ROOT}/protos" --python_out="${PACKAGE_ROOT}/grpc_model/src/auto_generated" --grpc_python_out="${PACKAGE_ROOT}/grpc_model/src/auto_generated" "${PACKAGE_ROOT}/protos/model2_template/model.proto"
