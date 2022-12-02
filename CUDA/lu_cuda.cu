#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>
#include <time.h>

#define N 12
//double A[N][N];

static void init_array(int n, double **A)
{
    
    //printf("Entro in init! \n");
    
    int i, j;
    
    for (i = 0; i < n; i++) {
        //printf("%d \n", i);
        for (j = 0; j < n; j++)
            //printf("%d \n", j);
            A[i][j] = ((double)(i + 1) * (j + 1)) / n;
    }
}

static void print_array(int n, double **A)
{
    int i, j;
    for (i = 0; i < n; i++)
    {
        for (j = 0; j < n; j++)
        {
            printf("%f ", A[i][j]);
        }
        printf("\n");
    }
    printf("\n");
}

static void kernel_lu(int n, double **A)
{
    int i, j, k;

    for (k = 0; k < n; k++)
    {
        for (j = k + 1; j < n; j++)
            A[k][j] = A[k][j] / A[k][k];
        for (i = k + 1; i < n; i++)
            for (j = k + 1; j < n; j++)
                A[i][j] = A[i][j] + A[i][k] * A[k][j];
    }
}

int main(int argc, char **argv)
{
    int n = N;
    struct timespec rt[2];
    double wt;
    double **A;
    A = (double **)malloc(n * sizeof(*A));

    for (int i = 0; i<n; i++){
        A[i] = (double *)malloc(n * sizeof(A));
    }
    //A = (double *) malloc(sizeof(*A) * n * n);

    init_array(n, A);
    print_array(n, A);
    clock_gettime(CLOCK_REALTIME, rt + 0);
    kernel_lu(n, A);
    clock_gettime(CLOCK_REALTIME, rt + 1);
    wt = (rt[1].tv_sec - rt[0].tv_sec) + 1.0e-9 * (rt[1].tv_nsec - rt[0].tv_nsec);
    printf("KERNEL_LU (Host) : %9.3f sec %9.1f GFLOPS\n", wt, 2.0 * n * n * n / (1.0e9 * wt));
    print_array(n, A);
    
    //kernel_lu(n);
    
}
