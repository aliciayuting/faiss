build_type=$1
if [ -z $FAISS_INSTALL_PREFIX ]; then
    install_prefix="/root/opt-dev"
else
    install_prefix=$FAISS_INSTALL_PREFIX
fi

# More about the flags setting checkout https://github.com/facebookresearch/faiss/blob/main/INSTALL.md 
cmake_defs="-DCMAKE_BUILD_TYPE=${build_type} -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_INSTALL_PREFIX=${install_prefix} -DFAISS_ENABLE_GPU=ON -DFAISS_ENABLE_PYTHON=ON -DFAISS_ENABLE_RAFT=OFF -DBUILD_TESTING=ON -DBUILD_SHARED_LIBS=ON -DFAISS_ENABLE_C_API=ON -DCUDAToolkit_ROOT=/usr/local/cuda-12.3 -DCMAKE_CUDA_ARCHITECTURES=\"75;72\""
build_path="build-${build_type}"

if [[ $2 == "USE_VERBS_API" ]]; then
    cmake_defs="${cmake_defs} -DUSE_VERBS_API=1"
fi

# begin building...
rm -rf ${install_prefix}/include/faiss ${install_prefix}/lib/libfaiss* ${install_prefix}/lib/cmake/faiss
rm -rf ${build_path} 2>/dev/null
cmake ${cmake_defs} -B ${build_path} .
NPROC=`nproc`
if [ $NPROC -lt 2 ]; then
    NPROC=2
fi
make -C ${build_path} -j `expr $NPROC - 1` 2>err.log
cd ..