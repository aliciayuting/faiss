
build_type=$1
if [ -z $FAISS_INSTALL_PREFIX ]; then
    install_prefix="/root/opt-dev"
else
    install_prefix=$FAISS_INSTALL_PREFIX
fi

if [ -z $CUDAToolKitRoot ]; then
    cudatoolkit_dir="/usr/local/cuda-12.3"
else
    cudatoolkit_dir=$CUDAToolKitRoot
fi

# More about the flags setting checkout https://github.com/facebookresearch/faiss/blob/main/INSTALL.md 
cmake_defs="-DCMAKE_BUILD_TYPE=${build_type} -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_INSTALL_PREFIX=${install_prefix} -DFAISS_ENABLE_GPU=ON -DFAISS_ENABLE_PYTHON=ON -DFAISS_ENABLE_RAFT=OFF -DBUILD_TESTING=ON -DBUILD_SHARED_LIBS=ON -DFAISS_ENABLE_C_API=ON -DCUDAToolkit_ROOT=${cudatoolkit_dir} -DCMAKE_CUDA_ARCHITECTURES=75;72"
build_path="build-${build_type}"

if [[ $2 == "USE_VERBS_API" ]]; then
    cmake_defs="${cmake_defs} -DUSE_VERBS_API=1"
fi

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
make -j faiss
make install
# cd ..

# Building python bindings
make -j swigfaiss
cd faiss/python
python setup.py install --user
cd ../../..