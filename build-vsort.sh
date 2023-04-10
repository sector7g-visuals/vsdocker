#!/bin/bash

set -xe
set -o pipefail

PREFIX=/usr/local

D0=/build
D1=/packages

export DEBIAN_FRONTEND=noninteractive

cleanup() {
    rm -rf $D0
}

invoke() {
    mkdir -p "$D0"
    cd "$D0"
    "install_$1"
}

install_deps() {
    apt-get update
    apt-get install --no-install-recommends -y git cmake python3 curl wget unzip
    rm -rf /var/lib/apt/lists/*
}

install_protobuf() {
    git clone --depth 1 -b v3.18.1 https://github.com/protocolbuffers/protobuf.git
    cmake -S protobuf/cmake -B protobuf/build_rel -LA \
        -D CMAKE_BUILD_TYPE=Release \
        -D protobuf_BUILD_SHARED_LIBS=OFF  -D protobuf_BUILD_TESTS=OFF \
        -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=true
    cmake --build protobuf/build_rel --verbose
    cmake --install protobuf/build_rel --prefix protobuf/install
}

install_onnx() {
    git clone --depth 1 -b v1.12.0 https://github.com/onnx/onnx.git
    cmake -S onnx -B onnx/build -LA \
        -D CMAKE_BUILD_TYPE=Release \
        -D Protobuf_PROTOC_EXECUTABLE=protobuf/install/bin/protoc \
        -D Protobuf_LITE_LIBRARY=protobuf/install/lib \
        -D Protobuf_LIBRARIES=protobuf/install/lib \
        -D ONNX_USE_LITE_PROTO=ON -D ONNX_USE_PROTOBUF_SHARED_LIBS=OFF \
        -D ONNX_GEN_PB_TYPE_STUBS=OFF -D ONNX_ML=0
    cmake --build onnx/build --verbose
    cmake --install onnx/build --prefix onnx/install
}

install_vsheaders () {
    curl -s -o vs.zip -L https://github.com/vapoursynth/vapoursynth/archive/refs/tags/R62.zip
    unzip -q vs.zip
    mv vapoursynth-*/include vapoursynth/ && rm -r vs.zip vapoursynth-*/
}

install_onnxruntime() {
    local ONNX_VER=1.14.1
    local ARCHIVE=onnxruntime-linux-x64-gpu-$ONNX_VER.tgz
    wget https://github.com/microsoft/onnxruntime/releases/download/v$ONNX_VER/onnxruntime-linux-x64-gpu-$ONNX_VER.tgz
    tar -xaf "$ARCHIVE"
    cp -r onnxruntime-linux-x64-gpu-$ONNX_VER/lib onnxruntime-linux-x64-gpu-$ONNX_VER/include "$PREFIX"
    rm -r $ARCHIVE onnxruntime-linux-x64-gpu-$ONNX_VER
}

_build_vsmlrt() {
    git checkout v14.test
    cd vsort
    mkdir -p build
    cmake -S . -B build -LA \
        -D CMAKE_BUILD_TYPE=Release \
        -D CMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded \
        -D VAPOURSYNTH_INCLUDE_DIRECTORY=$D0/vapoursynth \
        -D protobuf_DIR=$D0/protobuf/install/lib/cmake/protobuf \
        -D ONNX_DIR=$D0/onnx/install/lib/cmake/ONNX \
        -D ONNX_RUNTIME_API_DIRECTORY=$PREFIX/include/ \
        -D ONNX_RUNTIME_LIB_DIRECTORY=$PREFIX/lib \
        -D ENABLE_CUDA=1 \
        -D CMAKE_CXX_STANDARD=20 \
        -D CUDAToolkit_ROOT="/usr/local/cuda-11.8/bin"
    make -C build
    cmake --install build --prefix install
}

install_vs_mlrt() {
    git clone https://github.com/AmusementClub/vs-mlrt.git
    (cd vs-mlrt && _build_vsmlrt)
    mkdir -p "$D1"
    cp vs-mlrt/vsort/install/lib/* "$D1"/
    rm -rf vs-mlrt
}

install_vsort_all() {
    install_deps
    install_protobuf
    install_onnx
    install_vsheaders
    install_onnxruntime
    install_vs_mlrt
    cleanup
}

if [ -n "$1" ]; then
    invoke "$1"
fi
