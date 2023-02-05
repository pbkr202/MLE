//Parallel CUDA code to find parameters of gaussian distribution 
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include <bits/stdc++.h>

//N is the size of input array which we assume as points of gaussian distribution
#define N 10000000

using namespace std;

//This kernel finds the sum of the given input numbers in parallel by reducing the array recursively
__global__ void add(const float *input, float *output, int size) {

//Shared memory to store intermediate results among the threads
  __shared__ float partial_sum[256];
  
  int tid = threadIdx.x;
  int i = blockIdx.x * blockDim.x + threadIdx.x;
  float sum = 0.0f;

  while (i < size) {
    sum += input[i];
    i += blockDim.x * gridDim.x;
  }
  
  partial_sum[tid] = sum;
  __syncthreads();

//Reducing the size of array and finding the sum of partial array recursively
  for (int s = blockDim.x / 2; s > 0; s >>= 1) {
    if (tid < s) {
      partial_sum[tid] += partial_sum[tid + s];
    }
    __syncthreads();
  }

//Storing the result of current thread block in ouput
  if (tid == 0) {
    output[blockIdx.x] = partial_sum[0] ;
  }
}

//This kernel finds the square mean deviation sum of the given input numbers in parallel by reducing the array recursively
__global__ void square_add(const float *input, float *output, int size,float mean) {

//Shared memory among the threads
  __shared__ float partial_sum[256];
  int tid = threadIdx.x;
  int i = blockIdx.x * blockDim.x + threadIdx.x;
  float sum = 0.0f;

  while (i < size) {
    sum += (input[i]-mean)*(input[i]-mean);
    i += blockDim.x * gridDim.x;
  }
  partial_sum[tid] = sum;
  __syncthreads();

//Doing Parallel reduction recursively
  for (int s = blockDim.x / 2; s > 0; s >>= 1) {
    if (tid < s) {
      partial_sum[tid] += (partial_sum[tid + s]-mean)*(partial_sum[tid + s]-mean);
    }
    __syncthreads();
  }

//Storing result of current thread block
  if (tid == 0) {
    output[blockIdx.x] = partial_sum[0] ;
  }
}

int main(){
	srand(time(0));
	int blocks = N/256;
	//a contains input and ouput stores the intermediate values in finding mean,variance
	float *a,*output;
	float mean=0,variance=0,total=0,square_total=0;
	
	//Allocating memory for a,output
	cudaMallocManaged(&a, N*sizeof(float));
	cudaMallocManaged(&output, blocks*sizeof(float));
	
	//Assigning random numbers as input
	for(int i=0;i<N;i++)
	{
		a[i]= ((float)rand()) / RAND_MAX;
	}
	
	//Kernel launch for finding sum
	add<<<blocks, 256>>>(a, output, N);
	cudaDeviceSynchronize();
	
	//Calculating mean
	for (int i = 0; i < blocks; i++)
    {
        total+= output[i];
    }
	mean=total/N;
	
	//Kernel launch for finding square sum
	square_add<<<blocks,256>>>(a,output,N,mean);
	cudaDeviceSynchronize();
	
	//Calculating Variance
	for (int i = 0; i < blocks; i++)
    {
        square_total+= output[i];
    }
	variance=square_total/N;
	cout<<mean<<" "<<variance<<endl;
	cudaFree(a);
	cudaFree(output);
	return 0;
	}
