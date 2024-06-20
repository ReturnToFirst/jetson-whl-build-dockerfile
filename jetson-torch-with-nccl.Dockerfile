# This dockerfile must run on Jetson Orin series(AGX Orin, Orin NX)
FROM nvcr.io/nvidia/l4t-base:r36.2.0

ARG TORCH_VERSION=2.3.1
ARG MAX_JOBS=12 # For AGX Orin 64GB. adjust if you use other models.
ENV TORCH_SOURCE_URL=https://github.com/pytorch/pytorch/releases/download/v${TORCH_VERSION}/pytorch-v${TORCH_VERSION}.tar.gz

# Environment variables for build torch with nccl for orin
ENV USE_DISTRIBUTED=1
ENV USE_SYSTEM_NCCL=0
ENV USE_NCCL=1
ENV TORCH_CUDA_ARCH_LIST="8.7"

# Update and install require packages
RUN apt-get update
RUN apt-get install python3-pip \
                    python3-dev \
                    libopenblas-dev \
                    cmake \
                    ninja-build \
                    tar

# Download pytorch source file and unzip
WORKDIR /
RUN wget ${TORCH_SOURCE_URL}
RUN tar -xzf pytorch-v${TORCH_VERSION}.tar.gz

# Install python requirements and start build pytorch
WORKDIR /pytorch-v${TORCH_VERSION}
RUN pip3 install -r requirements.txt
RUN python3 setup.py bdist_wheel

# After build, move out .whl to /output for volume mount
RUN mkdir /output
RUN mv dist/torch* /output
