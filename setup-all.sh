#!/bin/bash

set -xe
set -o pipefail

PREFIX=/usr/local

invoke() {
    cd "/app"
    "install_$1"
}

install_mambapkgs() {
    mamba install -y jupyterlab
    mamba install -y -c conda-forge vapoursynth wget
    mamba install -y -c tongyuantongyu vapoursynth-ffms2 vapoursynth-cycmunet vapoursynth-mvsfunc vapoursynth-fmtconv
    pip install VSGAN s3cmd
}

install_onnxruntime() {
    local ONNX_VER=1.14.1
    local ARCHIVE=onnxruntime-linux-x64-gpu-$ONNX_VER.tgz
    wget https://github.com/microsoft/onnxruntime/releases/download/v$ONNX_VER/onnxruntime-linux-x64-gpu-$ONNX_VER.tgz
    tar -xaf "$ARCHIVE"
    sudo cp --no-preserve=ownership -r onnxruntime-linux-x64-gpu-$ONNX_VER/lib onnxruntime-linux-x64-gpu-$ONNX_VER/include "$PREFIX"
    sudo ldconfig
    rm -r $ARCHIVE onnxruntime-linux-x64-gpu-$ONNX_VER
}

install_vs_all() {
    install_mambapkgs
    install_onnxruntime
}

if [ -n "$1" ]; then
    invoke "$1"
fi
