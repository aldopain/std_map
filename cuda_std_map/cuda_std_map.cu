#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <inttypes.h>
#include <string.h>
#include <iostream>
#include <chrono>
#include <ctime>

#include <setjmp.h>
//#include "libjpeg/jpeglib.h"

#define pi 3.14159265358979323846
#define itCount 100000
#define tol 0.01

using namespace std;
using namespace std::chrono;

float *arr, *d_arr;
unsigned short *buf, *h_buf;
float yOffset = 0;
float xOffset = 0;
int p = 0;

int red[3] = { 255, 255, 255 };
int black[3] = { 255, 0, 0 };

void init (unsigned short size) {
  __int64 buf_size = p*p*itCount*2*sizeof(unsigned short);
  __int64 img_size = size*size*sizeof(float);

  cudaMalloc(&d_arr, img_size);
  cudaMalloc(&buf, buf_size);
  
  double mem = (buf_size + img_size)/1024/1024;
  cout << buf_size/1024/1024 << " MB allocated for buf" << '\n';
  cout << img_size/1024/1024 << " MB allocated for img" << '\n';
  cout << mem << " MB allocated on GPU" << '\n';

  arr = (float*)malloc(img_size);
  h_buf = (unsigned short*)malloc(buf_size);

  for (int i = 0; i < size * size; i++) {
    arr[i] = 0;
  }
  for (int i = 0; i < p*p*itCount*2; i++) {
    h_buf[i] = 0;
  }
  cudaMemcpy(d_arr, arr, img_size, cudaMemcpyHostToDevice);
  cudaMemcpy(buf, h_buf, buf_size, cudaMemcpyHostToDevice);
}

__device__
float mod2Pi (float a) {
  double x = (double)a;
  double m = (double)(2 * pi);
  return fmod(fmod(x, m) + m, m);
}

__device__
int sround(float v, int i, unsigned short size) {
  if (v < 0) v += 2 * pi;
  if (v > 2 * pi) v -= 2 * pi;
  return round (v * (size - 1) / (2 * pi));
}

__device__
void Drw1 (float x, float y, float *arr, unsigned short* buf, unsigned short size, float K, int thr){
  int st = thr * 2 * itCount;
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
    buf[st + i*2] = sround(mod2Pi(x), 0, size);
    buf[st + i*2 + 1] = sround(mod2Pi(y), 1, size);
  }
  float LLE = lsum / itCount;
  for (int i = 0; i < itCount; i++) {
    int ind = buf[st + i*2]*size + buf[st + i*2 + 1];
    arr[ind] = LLE;
  }
  __syncthreads();
}

__global__
void run (float step, float *arr, unsigned short *buf, unsigned short size, float K) {
  int i = blockIdx.x*blockDim.x + threadIdx.x;
  if (i < 2 * pi / step) {
    float pp = i * step;
    Drw1 (pp, 0, arr, buf, size, K, i);
    Drw1 (0, pp, arr, buf, size, K, i);
  }
}

void show (char* fileName, unsigned short size) {
  FILE *f = fopen("testr.ppm", "wb");
  fprintf(f, "P6\n%i %i 255\n", size, size);
  float summ = 0;
  cout << "CHECK arr[0] " << arr[0] << '\n';
  for (int i = 0; i < size; i++)
    summ += arr[size * (size - 1) + i];
  cout << "CHECK1 " << summ << '\n';
  summ = 0;
  for (int i = 0; i < size; i++) {
    //if (arr[i] != 0) {
      //cout << fixed;
      //cout << i << ". " << arr[i] << '\n';
    //}
    summ += arr[i];
  }
  cout << "CHECK2 " << summ << '\n';
  // for (int i = 0; i < size * size; i++)
  //   summ += arr[i];
  // cout << "CHECK2 " << summ << '\n';
  for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
          int* color;
          if (arr[y * size + x] < tol) color = red;
          else color = black;
          fputc(color[0], f);
          fputc(color[1], f);
          fputc(color[2], f);
      }
  }
  fclose(f);
}

void show2 (char* fileName, unsigned short size) {
  float summ = 0;
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      if (arr[y * size + x] >= 0) summ += arr[y * size + x];
      cout << arr[y * size + x] << " ";
    }
    cout << '\n';
  }
  cout << "summ: " << summ << '\n';
}

__int64 epoch() {
  return duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count();
}

void std_map (float k, float step, unsigned short size, char *fileName) {
  char str[64];
  cout << "started\n" << "K = " << k << "\nstep = " << step << "\nsize = " << size << '\n';
  p = sqrt(2 * pi/step) + 1;
  init(size);
  printf("init finished\n");
  __int64 p1 = epoch();
  cout << p << " blocks" << '\n';
  cout << p*p << " threads" << '\n';
  run<<<p, p>>>(step, d_arr, buf, size, k);
  cout << "time taken: " << epoch() - p1 << '\n';
  cudaMemcpy(arr, d_arr, size*size*sizeof(float), cudaMemcpyDeviceToHost);
  cout << "time taken: " << epoch() - p1 << '\n';

  p1 = epoch();
  show(strcat(str, fileName), size);
  cout << "time taken: " << epoch() - p1 << '\n';

  free(arr);
  cudaFree(d_arr);
  cudaFree(buf);
}

float* parse_args (int c, char **args) {
  float* res = (float*)malloc(3*sizeof(float));
  res[0] = 1;
  res[1] = 0.1;
  res[2] = 1000.0;
  switch (c) {
    case 4:
      res[2] = atof (args[3]);
    case 3:
      res[1] = atof (args[2]);
    case 2:
      res[0] = atof (args[1]);
  }
  return res;
}

int main(int argc, char *argv[])
{
  char name1[64] = "qwe1132123.ppm";
  float* a = parse_args (argc, argv);
  std_map (a[0], a[1], (unsigned short)a[2], name1);
}