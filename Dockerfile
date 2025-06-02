# Docker image for fastp read trimming
FROM ubuntu:22.04


LABEL maintainer="XNGZ"
LABEL maintainer="LYX"

# Install dependencies
RUN apt update && \
    apt install -y wget curl unzip g++ make zlib1g-dev libisal-dev libdeflate-dev dos2unix && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y file
RUN apt-get update && apt-get install -y bc
# Install fastp v0.25.0 from source
RUN wget https://github.com/OpenGene/fastp/archive/refs/tags/v0.25.0.zip -O fastp.zip && \
    unzip fastp.zip && \
    cd fastp-0.25.0 && \
    make && \
    make install && \
    cd .. && \
    rm -rf fastp-0.25.0 fastp.zip

# Set working directory
WORKDIR /root

# Download thread configuration script
RUN curl -o /root/set.thread.num.sh \
    https://raw.githubusercontent.com/cuhk-haosun/code-docker-script-lib/main/set.thread.num.sh && \
    chmod +x /root/set.thread.num.sh

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Convert line endings and set permissions
RUN apt install -y dos2unix && \
    dos2unix /entrypoint.sh && \
    chmod +x /entrypoint.sh && \
    apt purge -y dos2unix && \
    apt autoremove -y

# Verify script format
RUN file /entrypoint.sh && \
    head -1 /entrypoint.sh

# Entry point
ENTRYPOINT ["/entrypoint.sh"]
