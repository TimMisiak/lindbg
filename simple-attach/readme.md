This folder contains a simple example with a program written in C that gets put into a container along with the gdbserver executable. Running the container will start the 'fib' process, which can later be attached to using gdbserver.

To build:

```
docker build -t simple-attach .
```

To run the container:

```
docker run -it --rm -p 1234:1234 --cap-add=SYS_PTRACE --name simple-attach simple-attach
```

Note the presence of `--cap-add=SYS_PTRACE` which is needed to allow attaching to running processes.

To attach to this process, we'll need to start the gdbserver attached to the process. We'll use `pidof fib` so that it's a bit more flexible.

```
docker exec -it simple-attach sh -c 'gdbserver :1234 --attach $(pidof fib)'
```

To connect from windbg, you can enter `gdb:port=1234,server=localhost` into the "Connect to remote debugger" dialog, or run windbg from the command line:

```
windbgx -remote gdb:port=1234,server=localhost
```

It's important to note the distinction of the `-remote` parameter and not the `-premote` parameter. Using the `-remote` parameter tells the debugger to attach to an existing debug session (which was started with our gdbserver command). In the UI, the "Connect to remote debugger" dialog corresponds to the `-remote` option, and the "Connect to process server" corresponds to `-premote`. If you use the wrong option, it will look like your debug session is starting but then WinDbg gets confused and will report an error.

To set up source path automatically, you can run this from the directory containing the source (or specify the path instead of using `$pwd`):

```powershell
windbgx -remote gdb:port=1234,server=localhost -srcpath $pwd
```

```cmd
windbgx -remote gdb:port=1234,server=localhost -srcpath %CD%
```