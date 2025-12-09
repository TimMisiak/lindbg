FROM gcc:latest

WORKDIR /app

# Install gdbserver
RUN apt-get update && \
    apt-get install -y gdbserver && \
    rm -rf /var/lib/apt/lists/*

# Copy the source file
COPY fib.c .

# Build unoptimized with debug symbols
RUN gcc -O0 -g -o fib fib.c -Wl,--build-id

# Expose gdbserver port
EXPOSE 1234

# Run gdbserver in multi-process mode
CMD ["gdbserver", "--multi", "localhost:1234"]
