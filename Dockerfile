# ################ BUILD YUUNO ########################### #
# This needs lots of node deps for building but not for executing, so we
# build it in a separate image.
FROM docker.io/ubuntu:22.04 as yuuno-builder

ADD build-yuuno.sh /
RUN /build-yuuno.sh yuuno_all

# ################ BUILD VS-MLRT w/CUDA backend ########################### #
# This needs the development cuda packages
FROM docker.io/nvidia/cuda:11.8.0-devel-ubuntu22.04 as vsmlrt-builder

ADD build-vsort.sh /
RUN /build-vsort.sh vsort_all

# ################ The actual image ########################### #
FROM docker.io/anibali/pytorch:2.0.0-cuda11.8-ubuntu22.04

ADD setup-all.sh /
RUN /setup-all.sh vs_all

COPY --from=yuuno-builder /packages/yuuno*.tar.gz .
RUN pip install yuuno*.tar.gz && rm yuuno*.tar.gz

COPY --from=vsmlrt-builder /packages/libvsort.so /home/user/micromamba/lib/vapoursynth/

CMD jupyter-lab
