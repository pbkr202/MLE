//Serail cpp code to find parameters of gaussian distribution 
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <bits/stdc++.h>

//N is the size of input array which we assume as points of gaussian distribution
#define N 10000000

using namespace std;

//This function finds the sum of the given input
void add(float *a, int n ,float *total) {
    for(int i=0;i<n;i++)
    {
    	*total+=a[i];
    }
}

//This function finds the square mean deviation sum of given input
void square_add(float *a, int n ,float mean,float *square_total) {
    for(int i=0;i<n;i++)
    {
    	*square_total+=((a[i]-mean)*(a[i]-mean));
    }
}
int main(){
	srand(time(0));
	//a contains input representing points of gaussian distribution
	float *a,*total,*square_total;
	float mean=0,variance=0;
	
	//Allocating memory
	a=(float*) malloc(N*sizeof(float));
	total=(float*) malloc(sizeof(float));
	square_total=(float*) malloc(sizeof(float));
	*total=0;*square_total=0;
	
	//Assigning random numbers as input
	for(int i=0;i<N;i++)
	{
		a[i]= ((float)rand()) / RAND_MAX;
	}
	
	//Finding mean
	add(a,N,total);
	mean=*total/N;
	
	//Finding variance
	square_add(a,N,mean,square_total);
	variance=*square_total/N;
	cout<<mean<<" "<<variance<<endl;
	free(a);
	free(total);
	free(square_total);
	return 0;
}
