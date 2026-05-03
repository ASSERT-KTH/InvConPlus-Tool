# syntax=docker/dockerfile:1
FROM ubuntu:22.04

LABEL maintainer="ASSERT-KTH" \
      description="InvCon+: Automated Invariant Generation for Solidity Smart Contracts" \
      upstream="https://github.com/Franklinliu/InvConPlus-Tool" \
      paper="https://doi.org/10.1109/TDSC.2025.3592705"

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install all system dependencies in one layer
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3.10 \
        python3.10-dev \
        python3-pip \
        git \
        curl \
        wget \
        ca-certificates \
        build-essential \
        libssl-dev \
        libffi-dev \
        default-jdk \
        nodejs \
        npm \
        libcurl4-openssl-dev \
        clang \
        cmake \
        ninja-build \
        clang-format \
        jq \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.23 (required by chifra)
RUN wget -q https://go.dev/dl/go1.23.0.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.23.0.linux-amd64.tar.gz \
    && rm go1.23.0.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"

# Build and install chifra from source
# hadolint ignore=DL3003
RUN git clone --depth 1 --recurse-submodules \
        https://github.com/TrueBlocks/trueblocks-core.git /tmp/trueblocks \
    && cd /tmp/trueblocks \
    && bash scripts/go-work-sync.sh \
    && mkdir build \
    && cmake -GNinja -S src -B build \
    && ninja -C build \
    && cp build/bin/chifra /usr/local/bin/chifra \
    && rm -rf /tmp/trueblocks

WORKDIR /app

# Copy and install Python dependencies, patch API keys, verify import
COPY requirements.txt patch_keys.py ./
COPY . .
# hadolint ignore=DL3013
RUN pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir -r requirements.txt \
    && sed -i \
        's|etherscan_api_key="SDI5QEC2UAY1CX4C1VPXC4WE9HIMH2SF1C"|etherscan_api_key=os.environ.get("ETHERSCAN_API_KEY", "")|g' \
        invconplus/plugin/SourcecodeProvider.py \
    && python3 patch_keys.py \
    && python3 -c "import invconplus; print('invconplus import OK')"

# Runtime environment variables (must be provided at docker run time)
ENV ETHERSCAN_API_KEY="" \
    QUICKNODE_URL="" \
    RESULT_DIR="./Token-data/result"

CMD ["python3", "-m", "invconplus.main", "--help"]
