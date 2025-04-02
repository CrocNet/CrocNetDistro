## CrocNet Distro
### Build Linux Distros for Milk-V Duo ARM64 & RISC-V  
  

#### Distros

Ubuntu Bookworm - ARM64 & RISC-V
Debian Sid  - ARM64 & RISC-V
Debian Nobal - ARM64


  
Requires Docker installed.  
 
    git clone https://github.com/CrocNet/CrocNetDistro.git  
    cd CrocNetDistro

  
#### ./run.sh  
  
This builds the distro, using distro template. 

    ./run.sh  (menu driven)
    ./run.sh [arm64/riscv64] [distro dir]

  
#### ./makeTar.sh  
  
Builds tar file from `/rootfs`.   This is run automatically from run.sh, and
not normally requied. Useful if you want to make some changes to the file
system, before packaging. 

    ./makeTar.sh [rootfs dir]

#### Output

`/rootfs` is a working directory
`<distro>yyy-mm-dd.tar.gz` will be created when you enter root password.