#include <cmath>
#include <cstdlib>
#include <cstdio>
#include <chrono>
using namespace std;

__global__ void cuda_matmul(float *subA, float *subB, float *subC, int N) {
  int i = blockIdx.y;
  int j = threadIdx.x + blockDim.x * blockIdx.x;
  float sum = 0.0;
  extern __shared__ float S[];
  
  for (int ks=0; ks<N; ks+=blockDim.x) {
    __syncthreads();
    S[threadIdx.x] = subA[N*i+ks+threadIdx.x];
    __syncthreads();
    for (int k=ks; k<ks+blockDim.x; k++) {
      sum +=S[k-ks] * subB[N*k+j];
    }
  }
   atomicAdd(&subC[N*i+j], sum);
}

int main(int argc, char **argv) {
  
  int N = 2048;
  int M = 256;
  
  float *subA;
  float *subB;
  float *subC;
  cudaMallocManaged(&subA, N * N * sizeof(float));
  cudaMallocManaged(&subB, N * N * sizeof(float));
  cudaMallocManaged(&subC, N * N * sizeof(float));
  
  for (int i=0; i<N; i++) {
    for (int j=0; j<N; j++) {
      subA[N*i+j] = drand48();
      subB[N*i+j] = drand48();
      subC[N*i+j] = 0;
    }
  }
  
  
  auto tic = chrono::steady_clock::now();
  
  dim3 grid(N/M, N);
  cuda_matmul<<<grid,M,M*sizeof(float)>>>(subA, subB, subC, N);
  cudaDeviceSynchronize();
  
  auto toc = chrono::steady_clock::now();
  double comp_time = chrono::duration<double>(toc - tic).count();


  for (int i=0; i<N; i++)
    for (int k=0; k<N; k++)
      for (int j=0; j<N; j++)
        subC[N*i+j] -= subA[N*i+k] * subB[N*k+j];
  
  double err = 0;
  for (int i=0; i<N; i++)
    for (int j=0; j<N; j++)
      err += fabs(subC[N*i+j]);
  
  
  printf("N    : %d\n",N);
  printf("comp : %lf s\n", comp_time);
  printf("total: %lf s (%lf GFlops)\n", comp_time, 2.*N*N*N/comp_time/1e9);
  printf("error: %lf\n",err/N/N);
  
  cudaFree(subA);
  cudaFree(subB);
  cudaFree(subC);
}
