This folder contains a simple example of a container with a program that crashes and captures a core dump using [Sysinternals ProcDump for Linux](https://github.com/microsoft/ProcDump-for-Linux)

Using ProcDump avoids some of the complexities of configuring core dump collection on Linux, since containers do not have a completely isolated set of configuration options for core dump collection. The tradeoff is that the SYS_PTRACE capability needs to be enabled, which may not be possible in all environments.

To build:

```
docker build -t crash-procdump .
```

To run the container:

```powershell
docker run -it --rm --cap-add=SYS_PTRACE -v ${PWD}/cores:/cores --name crash-procdump crash-procdump
```





TODO: Look into `ELFBin: Head page of module 'crashme' is not mapped in core.`
Workaround is `.symopt +0x40` but this is dangerous.