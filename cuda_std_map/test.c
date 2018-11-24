#include <stdio.h>
#include <stdlib.h>
#define pi 3.14159265358979323846

int** arr;

float a = 10;

int main(void)
{
  arr = (int**)malloc(5*sizeof(int*));
  for (int i = 0; i < 5; i++) {
    arr[i] = (int*)malloc(5*sizeof(int));
    for (int j = 0; j < 5; j++)
      arr[i][j] = i;
  }
  for (int i = 0; i < 5; i++)
    for (int j = 0; j < 5; j++)
      printf("%d\n", arr[i][j]);
}