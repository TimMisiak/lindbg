This folder contains a simple example with a program written in C that gets put into a container along with the gdbserver executable. Running the container with port 1234 exposed gives you a container where you can connect to gdbserver on port 1234 and can launch the executable with WinDbg.

To build:

```
docker build -t simple-debug .
```

To run the container:

```
docker run -it --rm -p 1234:1234 --name simple-debug simple-debug
```

To connect from windbg, you can enter `gdb:port=1234,server=localhost` into the "Connect to process server" dialog, or run windbg from the command line:

```
windbgx -premote gdb:port=1234,server=localhost "\/app/fib"
```

Note that due to some weirdness in the WinDbg command line parser (my fault actually), you can't start an executable path with a `/` character. You can work around this by starting the path with a `\/` which ends up getting ignored by gdbserver. To set up source path automatically, you can use:

```powershell
windbgx -premote gdb:port=1234,server=localhost -srcpath $pwd "\/app/fib"
```

```cmd
windbgx -premote gdb:port=1234,server=localhost -srcpath %CD% "\/app/fib"
```

Once WinDbg is running, you can now run a `g fib!main` command to run the executable until the start of the main function.

Note that example executable being run takes input and writes output to the console, which will be in the same console where you ran the `docker run` command.