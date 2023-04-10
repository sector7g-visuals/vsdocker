#!/bin/bash

set -xe
set -o pipefail

PREFIX=/usr/local
THIS_SCRIPT_DIR=$(dirname "$0")

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
    apt-get install --no-install-recommends -y git python3 python3-setuptools python3-pip npm python3.10-venv
    rm -rf /var/lib/apt/lists/*
}

_build_yuuno() {
    npm install --legacy-peer-deps yarn
    export PATH=$PATH:$(pwd)/node_modules/.bin
    python3 setup.py sdist
}

install_yuuno() {
    python3 -m venv venv
    . venv/bin/activate
    pip install notebook jupyterlab
    git clone https://github.com/Irrational-Encoding-Wizardry/yuuno.git
    (cd yuuno && _build_yuuno)
    mkdir -p "$D1"
    cp yuuno/dist/* "$D1"/
    rm -rf yuuno
}

install_yuuno_all() {
    install_deps
    install_yuuno
    cleanup
}

if [ -n "$1" ]; then
    invoke "$1"
fi
