cmake -DCMAKE_INSTALL_PREFIX=/root/opt-dev -DFAISS_ENABLE_GPU=ON -DFAISS_ENABLE_PYTHON=ON -DFAISS_ENABLE_RAFT=OFF -DBUILD_TESTING=ON -DBUILD_SHARED_LIBS=ON -DFAISS_ENABLE_C_API=ON -DCUDAToolkit_ROOT=/usr/local/cuda-12.3 -DCMAKE_CUDA_ARCHITECTURES="75;72"  -B build .