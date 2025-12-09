FROM gcc:latest

WORKDIR /app

# Install Procdump from github releases
# This is the only place where version 3.5 is available, which has some features we need that aren't in 2.2 available via package manager.

# Install dependencies for .deb install
RUN apt-get update && apt-get install -y wget lsb-release && \
    rm -rf /var/lib/apt/lists/*

# Download and install ProcDump .deb from GitHub
RUN wget -q https://github.com/microsoft/ProcDump-for-Linux/releases/download/3.5.0/procdump_3.5.0_amd64.deb -O /tmp/procdump.deb && \
    apt-get update && apt-get install -y /tmp/procdump.deb && \
    rm /tmp/procdump.deb && \
    rm -rf /var/lib/apt/lists/*
    
COPY crashme.c .

# Build unoptimized with debug symbols
RUN gcc -O0 -g -o crashme crashme.c -Wl,--build-id


COPY entrypoint.sh .
RUN chmod +x /app/entrypoint.sh

CMD ["/app/entrypoint.sh"]
