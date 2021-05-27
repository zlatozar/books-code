## Set up the cross compiler

1. Extract `cross-compiler/mips-x86.linux-xgcc.tar.gz` using `tar -xzvf mips-x86.linux-xgcc.tar.gz`.

The location of this folder will be used in the following step. You can go to this folder and get the absolute path of this folder:
```text
cd mips-x86.linux-xgcc/
pwd
```

2. Set environment variable `ARCHDIR` in `.bashrc` in your HOME directory.
```shell
export ARCHDIR=Your mips cp dir
export PATH=$ARCHDIR:Your nachos bin dir:$PATH
```
