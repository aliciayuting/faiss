
if [ -z "$1" ]; then
    build_path="build"
else
    build_type=$1
    build_path="build-${build_type}"
fi

# TODO: change it to your own path
if [ -z $FAISS_INSTALL_PREFIX ]; then
    install_prefix="/home/yy354/opt-dev"
else
    install_prefix=$FAISS_INSTALL_PREFIX
fi

# TODO: change it to cuda version on your server
if [ -z $CUDAToolKitRoot ]; then
    cudatoolkit_dir="/usr/local/cuda-12.3"
else
    cudatoolkit_dir=$CUDAToolKitRoot
fi

# Note:
# DCMAKE_CUDA_ARCHITECTURES: specify the target CUDA architectures. (When changing GPU machine, also check to see if this needs to be changed)
# More about the flags setting checkout https://github.com/facebookresearch/faiss/blob/main/INSTALL.md 
cmake_defs="-DCMAKE_BUILD_TYPE=${build_type} -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_INSTALL_PREFIX=${install_prefix} -DFAISS_ENABLE_GPU=ON -DFAISS_ENABLE_PYTHON=ON -DFAISS_ENABLE_RAFT=OFF -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=ON -DFAISS_ENABLE_C_API=ON -DCUDAToolkit_ROOT=${cudatoolkit_dir} -DCMAKE_CUDA_ARCHITECTURES=60;75;72"



# begin building...
rm -rf ${install_prefix}/include/faiss ${install_prefix}/lib/libfaiss* ${install_prefix}/lib/cmake/faiss
rm -rf ${build_path} 2>/dev/null
mkdir ${build_path}
cd ${build_path}
cmake ${cmake_defs} ..
NPROC=`nproc`
if [ $NPROC -lt 2 ]; then
    NPROC=2
fi
make faiss -j `expr $NPROC - 1` 2>err.log
make install

# Building python bindings
read -p "Install FAISS Python interface? (y/n): " response
response=${response,,}

if [[ "$response" == "y" ]]; then
    echo "Installing FAISS Python interface..."
    make -j swigfaiss
    cd faiss/python
    python setup.py install --user
    cd ../../..
elif [[ "$response" == "n" ]]; then
    echo "Installation skipped."
    cd ..
else
    echo "Invalid response. Please enter 'y' or 'n'."
fi