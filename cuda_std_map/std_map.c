#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#define _POSIX_C_SOURCE 199309L
#include <sys/time.h>
#include <inttypes.h>
#include <string.h>
#define pi 3.14159265358979323846

int size = 1000;
float** arr;
int** traectory;
int itCount = 100000;
float tPi = 2 * pi;
float yOffset = 0;
float xOffset = 0;
float K = 1;
int red[3] = { 255, 255, 255 };
int black[3] = { 0, 0, 0 };
float tol = 0.01;

// __global__
// void saxpy(int n, float a, float *x, float *y)
// {
//   int i = blockIdx.x*blockDim.x + threadIdx.x;
//   if (i < n) y[i] = a*x[i] + y[i];
// }

void init () {
  arr = (float**)malloc(size*sizeof(float*));
  for (int i = 0; i < size; i++) {
    arr[i] = (float*)malloc(size*sizeof(float));
    for (int j = 0; j < size; j++)
      arr[i][j] = 0;
  }
  traectory = (int**)malloc(itCount*sizeof(int*));
  for (int i = 0; i < itCount; i++)
    traectory[i] = (int*)malloc(2*sizeof(int));
}

float mod2Pi (float a) {
  return fmod (a, tPi);
}

int sround(float v, int i) {
  // if (i == 1)
  //   if (v < yOffset) v += yOffset; else v -= yOffset;
  // else 
  //   if (v < xOffset) v += xOffset; else v -= xOffset;
  if (v < 0) v += tPi;
  if (v > tPi) v -= tPi;
  return round (v * (size - 1) / (tPi));
}

void Drw1 (float x, float y){
  float ep = 1;
  float eq = 0;
  float lsum = 0;
  for (int i = 0; i < itCount; i++) {
    x = mod2Pi (x + K * sin(y));
    y = mod2Pi (y + x);
    float dq = K * cos(y);
    float epn = ep + dq * eq;
    float eqn = ep + (1 + dq) * eq;
    ep = epn;
    eq = eqn;
    float dn = sqrt(ep * ep + eq * eq);
    ep = ep / dn;
    eq = eq / dn;
    lsum += log(dn);
    traectory[i][0] = sround(mod2Pi(x), 0);
    traectory[i][1] = sround(mod2Pi(y), 1);
  }
  float LLE = lsum / itCount;
  for (int i = 0; i < itCount; i++) {
    if (arr[traectory[i][0]][traectory[i][1]] == 0)
      arr[traectory[i][0]][traectory[i][1]] = LLE;
  }
}

void run (float step) {
  float s = 0;
  for (float t0 = 0; t0 < 2 * pi; t0 += step) {
    // printf("%f\n", t0);
    Drw1 (s, t0);
    Drw1 (t0, s);
  }
}

void show (char* fileName) {
  printf(fileName);
  FILE *f = fopen(fileName, "wb");
  fprintf(f, "P6\n%i %i 255\n", size, size);
  for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
          int* color;
          if (arr[y][x] < tol) color = red;
          else color = black;
          fputc(color[0], f);
          fputc(color[1], f);
          fputc(color[2], f);
      }
  }
  fclose(f);
}

void std (float k, float step, int s, char* fileName) {
  K = k;
  size = s;

  struct timeval start, stop, stop2;
  double secs = 0;
  char str[64];

  printf("started\n");
  init();
  printf("init finished\n");

  gettimeofday(&start, NULL);
  run(step);
  gettimeofday(&stop, NULL);
  secs = (double)(stop.tv_usec - start.tv_usec) / 1000000 + (double)(stop.tv_sec - start.tv_sec);
  printf("time taken %f\n",secs);

  show(strcat(str, fileName));
  gettimeofday(&stop2, NULL);
  secs = (double)(stop2.tv_usec - stop.tv_usec) / 1000000 + (double)(stop2.tv_sec - stop.tv_sec);
  printf("time taken %f\n",secs);

  free(arr);
  free(traectory);
}

int main(void)
{
  char name1[64] = "qwe1132123.ppm";
  char name2[64] = "qwe2.ppm";
  printf(name1);
  printf(name2);

  std(1, 0.001, 20000, name1);
  // std(2, 0.1, 2000, name2);
  // float *d_arr;

  // cudaMalloc(&d_x, N*sizeof(float)); 
  // cudaMalloc(&d_y, N*sizeof(float));

  // cudaMemcpy(d_x, x, N*sizeof(float), cudaMemcpyHostToDevice);
  // cudaMemcpy(d_y, y, N*sizeof(float), cudaMemcpyHostToDevice);

  // Perform SAXPY on 1M elements
  // saxpy<<<(N+255)/256, 256>>>(N, 2.0f, d_x, d_y);

  // cudaMemcpy(y, d_y, N*sizeof(float), cudaMemcpyDeviceToHost);

  // cudaFree(d_arr);
}