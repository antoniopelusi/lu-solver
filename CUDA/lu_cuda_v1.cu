#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>
#include <time.h>

#include <cuda_runtime.h>

#define N 1024
#define BLOCK_SIZE 32

#define gpuErrchk(ans)                        \
    {                                         \
        gpuAssert((ans), __FILE__, __LINE__); \
    }
static inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort = true)
{
    if (code != cudaSuccess)
    {
        fprintf(stderr, "GPUassert: %s %s %d\n", cudaGetErrorString(code), file, line);
        if (abort)
            exit(code);
    }
}


static void init_array(int n, float *A)
{    
    int i, j;
    
    for (i = 0; i < n; i++) {
        for (j = 0; j < n; j++)
            A[i*n+j] = ((float)(i + 1) * (j + 1)) / n;
    }
}

static void print_array(int n, float *A)
{
    int i, j;
    for (i = 0; i < n; i++)
    {
        for (j = 0; j < n; j++)
        {
            printf("%f ", A[i*n+j]);
        }
        printf("\n");
    }
    printf("\n");
}


static void kernel_lu(int n, float *A)
{
    int i, j, k;

    for (k = 0; k < n; k++)
    {
        for (j = k + 1; j < n; j++)
            A[k*n+j] = A[k*n+j] / A[k*n+k];
        for (i = k + 1; i < n; i++)
            for (j = k + 1; j < n; j++)
                A[i*n+j] = A[i*n+j] + A[i*n+k] * A[k*n+j];
    }
}

__global__ void gpu_kernel_lu(float * __restrict__ A, int k, int n)
{
    int i = threadIdx.y + blockIdx.y * blockDim.y;
    int j = threadIdx.x + blockIdx.x * blockDim.x;

    if (i<n && j<n && i>k && j>k)
    {
	if(i==n-1)
	{
            A[k*n+j] = A[k*n+j] / A[k*n+k];
	}
        __syncthreads();

        A[i*n+j] = A[i*n+j] + A[i*n+k] * A[k*n+j];
    }
}

int main(int argc, char **argv)
{
    int n = N;
    int k = 0;
    struct timespec rt[2];
    double wt;
    float *A;
    A = (float *)malloc(n * n * sizeof(*A));

    init_array(n, A);
    clock_gettime(CLOCK_REALTIME, rt + 0);
    kernel_lu(n, A);
    clock_gettime(CLOCK_REALTIME, rt + 1);
    wt = (rt[1].tv_sec - rt[0].tv_sec) + 1.0e-9 * (rt[1].tv_nsec - rt[0].tv_nsec);
    printf("KERNEL_LU (Host) : %9.3f sec %9.1f GFLOPS\n", wt, 2.0 * n * n * n / (1.0e9 * wt));
    //print_array(n, A);

    init_array(n, A);
    
    //cudaMalloc
    float *d_A;
    gpuErrchk(cudaMalloc((void **)&d_A, sizeof(float) * n * n));

    //cudamemcopy
    struct timespec rt2[2];
    double wt2;
    clock_gettime(CLOCK_REALTIME, rt2 + 0);

    gpuErrchk(cudaMemcpy(d_A, A, sizeof(float) * n * n, cudaMemcpyHostToDevice));    

    dim3 dimGrid((n+BLOCK_SIZE-1)/BLOCK_SIZE, (n+BLOCK_SIZE-1)/BLOCK_SIZE);
    dim3 dimBlock(BLOCK_SIZE,BLOCK_SIZE);
   
   
    for (k = 0; k<n; k++)
        gpu_kernel_lu<<<dimGrid, dimBlock>>>(d_A, k, n);

   
    gpuErrchk(cudaMemcpy(A, d_A, sizeof(float) * n * n, cudaMemcpyDeviceToHost));    

    clock_gettime(CLOCK_REALTIME, rt2 + 1);

    wt2 = (rt2[1].tv_sec - rt2[0].tv_sec) + 1.0e-9 * (rt2[1].tv_nsec - rt2[0].tv_nsec);
    printf("KERNEL_LU (GPU) : %9.3f sec %9.1f GFLOPS\n", wt2, 2.0 * n * n * n / (1.0e9 * wt2));

    //print_array(n, A);

    cudaDeviceReset();
    return 0;
}
