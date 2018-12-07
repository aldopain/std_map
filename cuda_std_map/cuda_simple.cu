#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#define _POSIX_C_SOURCE 199309L
#include <time.h>
#include <inttypes.h>
#include <string.h>
#include <iostream>
#include <chrono>
#include <ctime>
#define tPi 6.28318530718
#define itCount 100000
#define p 3

using namespace std;
using namespace std::chrono;

__global__
void simp(int *y, float step)
{
  int ind = blockIdx.x*blockDim.x + threadIdx.x;
  y[ind] = 2 * itCount * ind + 199999;
}


// void cpu_saxpy(float* y, float* x, int n) {
//   for (int i = 0; i < n; i++)
//     y[i] = a * x[i] + y[i];
// }

__int64 epoch() {
  return duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count();
}

int main(void)
{
  int N = 200;
  printf("N: %i\n", N);
  int *d_y, *y;
  __int64 p1;
  y = (int*)malloc(N*sizeof(int));

  cudaMalloc(&d_y, N*sizeof(int));

  for (int i = 0; i < N; i++) {
    y[i] = 0;
  }

  cudaMemcpy(d_y, y, N*sizeof(int), cudaMemcpyHostToDevice);

  p1 = epoch();
  simp<<<1, N>>>(d_y, N);
  cout << "time taken: " << epoch() - p1 << '\n';
  cudaMemcpy(y, d_y, N*sizeof(int), cudaMemcpyDeviceToHost);
  for (int i = 0; i < N; i++) {
    cout << fixed << i << ". " << y[i] << '\n';
  }

  cudaFree(d_y);
  free(y);
}