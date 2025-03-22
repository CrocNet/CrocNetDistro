## CrocNet Distro
### Build Linux Distros for Milk-V Duo ARM64 & RISC-V  
  
  
Requires Docker installed.  
 
    git clone https://github.com/CrocNet/CrocNetDistro.git  
    cd CrocNetDistro

  
#### ./run.sh  
  
This builds the distro, using distro template. 

    /run.sh  
    ./run.sh [arm64/riscv64] [distro dir]

Your complete image will be in the `images` directory.  
  
#### ./makeTar.sh  
  
Builds tar file from RootFS.   This is run automatically from run.sh

    ./makeTar.sh  
    ./makeTar.sh [rootfs dir]