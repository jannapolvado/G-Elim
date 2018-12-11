/******************************************************************************
 *cr
 *cr            (C) Copyright 2010 The Board of Trustees of the
 *cr                        University of Illinois
 *cr                         All Rights Reserved
 *cr
 ******************************************************************************/

#include <stdio.h>

#define TILE_SZ 16 

__global__ void Gelim(float *A,  int numvar){/////////////add b back in middle

    __shared__ float A_s[TILE_SZ][TILE_SZ];
    int Tirow = threadIdx.y;
    int Ticol = threadIdx.x;
  
    A_s[Tirow][Ticol] = A[(Tirow * (numvar +1)) + Ticol];
       
    for(int i = 1; i < numvar; i++){
       
        if((Tirow +i) < (numvar)){
          
            float multiplier = A_s[Tirow+i][i-1]/A_s[i-1][i-1];
            if(Tirow  <= Ticol+1){
                A_s[Tirow+i][Ticol] -= (multiplier * A_s[i-1][Ticol]);
            }
            else{
                A_s[Tirow+i][Ticol] = 0;
            }
            __syncthreads();
        }
        //__syncthreads();
    }
    A[Tirow *(numvar+1) +Ticol] = A_s[Tirow][Ticol];/////////////replace a with b

}

   

void basicGelim(float *A,  int numvar){ ////////add b back in middle
    dim3 block(numvar+1, numvar, 1);
    dim3 grid(1,1,1);

    Gelim<<<grid,block>>>(A,numvar);//////////b  back in mid

}

/*void basicSgemm(char transa, char transb, int m, int n, int k, float alpha, const float *A, int lda, const float *B, int ldb, float beta, float *C, int ldc)
{
    if ((transa != 'N') && (transa != 'n')) {
	printf("unsupported value of 'transa'\n");
    	return;
    }

    if ((transb != 'N') && (transb != 'n')) {
	printf("unsupported value of 'transb'\n");
	return;
    }

    if ((alpha - 1.0f > 1e-10) || (alpha - 1.0f < -1e-10)) {
	printf("unsupported value of alpha\n");
	return;
    }

    if ((beta - 0.0f > 1e-10) || (beta - 0.0f < -1e-10)) {
	printf("unsupported value of beta\n");
	return;
    }*/

    // Initialize thread block and kernel grid dimensions ---------------------

   /* const unsigned int BLOCK_SIZE = TILE_SZ;
    dim3 block(BLOCK_SIZE,BLOCK_SIZE);
    dim3 grid((n+BLOCK_SIZE-1)/BLOCK_SIZE,(m+BLOCK_SIZE-1)/BLOCK_SIZE);
    //INSERT CODE HERE

    // Invoke CUDA kernel -----------------------------------------------------
    mysgemm<<<grid,block>>>(m,n,k,A,B,C);
    //INSERT CODE HERE
    dim3 block(numvar+1,numvar,1);
    dim3 grid(1,1,1);



}*/
