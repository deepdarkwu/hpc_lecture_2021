## Student ID: 21M12272

## Name: WU ZHUOFENG


# Result

**Tested in Tsubame f-node**

**Used Matrix N=2048**

**4 processed for mpi**

|              Method             |  Time (s) |   GFlops    |   Error    |
|---------------------------------|-----------|-------------|------------|
|  MPI(example)                   | 34.253257 |    0.501554 |  0.000364  |
|  MPI+openmp                     |  5.137721 |    3.343870 |  0.000364  |
|  MPI+openmp+SIMD                |  0.859402 |   19.990485 |  0.000364  |
|  MPI+openmp+SIMD+CacheBlocking  |  0.049206 |  349.140059 |  0.000258  |
|  Cuda                           |  0.052758 |  325.635400 |  0.000364  |
|  MPI+Cuda                       |  1.605541 |   10.700359 |  0.000364  |

# Module Load
## For MPI+Openmp+SIMD+CacheBlocking
module load gcc

module load intel-mpi

## For MPI+CUDA

module load gcc

module load cuda/11.2.146

module load openmpi


# Command

## MPI(example)
mpicxx example.cpp

mpirun -np 4 ./a.out

## MPI+Openmp 
mpicxx mpi_openmp.cpp -fopenmp

mpirun -np 4 ./a.out

## MPI+Openmp+SIMD
mpicxx mpi_openmp_simd.cpp -fopenmp -fopt-info-optimized -march=native -O3

mpirun -np 4 ./a.out

## MPI+Openmp+SIMD+CacheBlocking
mpicxx mpi_openmp_simd_cacheBlocking.cpp -fopenmp -fopt-info-optimized -march=native -O3

mpirun -np 4 ./a.out

## CUDA
nvcc cuda.cu

./a.out

## MPI+CUDA
nvcc mpi_cuda.cu -lmpi

./a.out
