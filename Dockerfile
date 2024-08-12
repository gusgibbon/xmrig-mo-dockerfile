FROM ubuntu:latest AS builder

# deps
RUN apt update -y \
    && apt install -y wget git build-essential cmake libuv1-dev libssl-dev libhwloc-dev \
    && wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb \
    && dpkg -i cuda-keyring_1.1-1_all.deb \
    && apt -y update \
    && apt -y install cuda-toolkit-12-6
    
# xmrig
RUN mkdir -p /opt/xmrig/ \
    && git clone --depth=1 "https://github.com/MoneroOcean/xmrig.git" "/opt/xmrig" \
    && sed -i -e 's/kMinimumDonateLevel = 1/kMinimumDonateLevel = 0/g' /opt/xmrig/src/donate.h \
    && sed -i -e 's/kDefaultDonateLevel = 1/kDefaultDonateLevel = 0/g' /opt/xmrig/src/donate.h \
    && mkdir /opt/xmrig/build \
    && cd /opt/xmrig/build \
    && cmake .. \
    && make -j "$(nproc)"

# xmrig nvidia plugin (currently broken)
# RUN mkdir -p /opt/xmrig-cuda/ \
#     && git clone --depth=1 "https://github.com/MoneroOcean/xmrig-cuda.git" "/opt/xmrig-cuda" \
#     && mkdir /opt/xmrig-cuda/build \
#     && cd /opt/xmrig-cuda/build \
#     && cmake .. -DCUDA_LIB=/usr/local/cuda/lib64/stubs/libcuda.so -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda \
#     && make -j "$(nproc)"

FROM ubuntu:latest

RUN apt update -y \
    && apt install -y wget libuv1-dev libssl-dev libhwloc-dev \
    && wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb \
    && dpkg -i cuda-keyring_1.1-1_all.deb \
    && apt -y update \
    && apt -y install nvidia-open cuda-toolkit-12-6
    
COPY --from=builder /opt/xmrig/build/xmrig /xmrig/xmrig
# COPY --from=builder /opt/xmrig-cuda/build/libxmrig-cuda.so /xmrig/libxmrig-cuda.so

ENV PATH=/xmrig:$PATH
