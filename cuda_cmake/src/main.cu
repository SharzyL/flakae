#include <iostream>
#include <vector>
#include <cuda_runtime.h>

__global__ void vectorAdd(const float* A, const float* B, float* C, int n) {
    int idx = blockDim.x * blockIdx.x + threadIdx.x;
    if (idx < n)
        C[idx] = A[idx] + B[idx];
}

int main() {
    int n = 1 << 20;
    size_t size = n * sizeof(float);
    std::vector<float> h_A(n, 1.0f), h_B(n, 2.0f), h_C(n);

    float *d_A, *d_B, *d_C;
    if (cudaMalloc((void**)&d_A, size) != cudaSuccess ||
        cudaMalloc((void**)&d_B, size) != cudaSuccess ||
        cudaMalloc((void**)&d_C, size) != cudaSuccess) {
        std::cerr << "Error allocating memory on GPU" << std::endl;
        return -1;
    }

    cudaMemcpy(d_A, h_A.data(), size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B.data(), size, cudaMemcpyHostToDevice);

    int threadsPerBlock = 256;
    int blocksPerGrid = (n + threadsPerBlock - 1) / threadsPerBlock;
    vectorAdd<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, n);

    cudaMemcpy(h_C.data(), d_C, size, cudaMemcpyDeviceToHost);

    std::cout << "Result[0,1,2]: " << h_C[0] << ", " << h_C[1] << ", " << h_C[2] << std::endl;

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);
    return 0;
}

