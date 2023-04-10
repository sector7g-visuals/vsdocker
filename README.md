# Vapoursynth Docker Container

![Docker Image Version (latest by date)](https://img.shields.io/docker/v/jcarrano/vapoursynth-ai?style=for-the-badge) ![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/jcarrano/vapoursynth-ai?style=for-the-badge)

## Repo

https://github.com/sector7g-visuals/vsdocker

## Aim

This is meant to make it easy to run Vapoursynth on cloud GPUs. It will
include:

- Vapoursynth
- Pytorch
- CUDA
- onnxruntime
- ffmpeg
- Vapoursynth Plugins
  - ffms2
  - VSGAN
  - vs-mlrt (with onnxruntime/CUDA backend)
  - cycmunet (untested)
  - mvsfunc
  - fmtconv
- Jupyter
  - Yuuno extension
