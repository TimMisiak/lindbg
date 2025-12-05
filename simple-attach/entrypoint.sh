#!/bin/sh
./fib &
gdbserver localhost:1234
