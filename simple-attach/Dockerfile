FROM gcc:latest

WORKDIR /app

# Install gdbserver
RUN apt-get update && \
    apt-get install -y gdbserver && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh .
RUN chmod +x /app/entrypoint.sh
COPY fib.c .

# Build unoptimized with debug symbols
RUN gcc -O0 -g -o fib fib.c

# Expose gdbserver port
EXPOSE 1234

# Run gdbserver and the demo app
ENTRYPOINT ["/app/fib"]
