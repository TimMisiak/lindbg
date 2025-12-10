This folder contains a mult-container debug setup so that the main container has no debug components, but a second "sidecar" container can attach to processes in the first one. While docker can share the process namespace with `--pid=container:<container>`, we'll still need access to the target binaries, so this will require a little extra work to copy the binaries over into the debug container. We leave this to the `entrypoint.sh` script, which finds all processes running out of the `/app` directory and copies them into a local `/app` directory.


To build:

```
docker build -t sidecar-target -f .\TargetDockerfile .
docker build -t sidecar-debugger -f .\DebuggerDockerfile .
```

To run:

```
docker run -it --rm --name sidecar-target sidecar-target
docker run --rm -p 1234:1234 --privileged --pid=container:sidecar-target --name sidecar-debugger sidecar-debugger

```

From here you can "connect to process server" in windbg or run with the `-premote` command argument.

```
windbgx -premote gdb:port=1234,server=localhost
```

This will allow you to attach to the `fib` process and debug normally.

Since the debugger container and target container are built from the same base image, the dynamic libraries will match, which will improve debugging support, allowing things like stack walking to work through libc.so

Note: WinDbg is currently crashing when attempting to break into a running process, but breakpoints will still work normally.