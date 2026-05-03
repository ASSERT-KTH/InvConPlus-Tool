# syntax=docker/dockerfile:1
FROM ubuntu:22.04

LABEL maintainer="ASSERT-KTH" \
      description="InvCon+: Automated Invariant Generation for Solidity Smart Contracts" \
      upstream="https://github.com/Franklinliu/InvConPlus-Tool" \
      paper="https://doi.org/10.1109/TDSC.2025.3592705"

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install system dependencies
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
        # Java required by Daikon
        default-jdk \
        # Node.js required by AutoAnnotation/VeriSol pipeline
        nodejs \
        npm \
    && rm -rf /var/lib/apt/lists/*

# Install chifra (TrueBlocks) for transaction listing
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
        libcurl4-openssl-dev \
        clang \
        cmake \
        ninja-build \
    && rm -rf /var/lib/apt/lists/*

# Install Go (required to build chifra from source)
RUN wget -q https://go.dev/dl/go1.21.0.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz \
    && rm go1.21.0.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"

# Build and install chifra from source
RUN git clone --depth 1 https://github.com/TrueBlocks/trueblocks-core.git /tmp/trueblocks \
    && cd /tmp/trueblocks \
    && mkdir build && cd build \
    && cmake -GNinja .. \
    && ninja \
    && cp bin/chifra /usr/local/bin/chifra \
    && rm -rf /tmp/trueblocks

WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt .
# hadolint ignore=DL3013
RUN pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir -r requirements.txt

# Copy source
COPY . .

# Patch hardcoded API keys to use environment variables
# 1. Etherscan key in SourcecodeProvider.py
RUN sed -i \
    's|etherscan_api_key="SDI5QEC2UAY1CX4C1VPXC4WE9HIMH2SF1C"|etherscan_api_key=os.environ.get("ETHERSCAN_API_KEY", "")|g' \
    invconplus/plugin/SourcecodeProvider.py

# 2. QuickNode URL in quickNode.py - use Python to avoid shell escaping issues
RUN python3 - <<'EOF'
import re
path = "invconplus/plugin/quickNode.py"
content = open(path).read()
content = re.sub(
    r"url = 'https://[^']+quiknode\.pro/[^']*/'",
    "url = os.environ.get('QUICKNODE_URL', '')",
    content
)
if "import os" not in content:
    content = "import os\n" + content
open(path, "w").write(content)
EOF

# Verify the module is importable
RUN python3 -c "import invconplus; print('invconplus import OK')"

# Runtime environment variables (must be provided at docker run time)
ENV ETHERSCAN_API_KEY="" \
    QUICKNODE_URL="" \
    RESULT_DIR="./Token-data/result"

CMD ["python3", "-m", "invconplus.main", "--help"]
