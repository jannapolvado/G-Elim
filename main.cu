/******************************************************************************
 * Janna Polvado
 * Massive Parallel Programming
 * Gaussian Elimination 
 ******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include "kernel.cu"
#include "support.h"

int main (int argc, char *argv[])
{

    //printf("THIS IS A TEST!!!!!\n");
    Timer timer, runtimer;
    cudaError_t cuda_ret;
    //startTime(&runtimer);
    // Initialize host variables ----------------------------------------------

    printf("\nSetting up the problem..."); fflush(stdout);
    startTime(&timer);

   
    unsigned int matArow, matAcol;
    dim3 dim_grid, dim_block;
    float *A_h, *A_d, *result, sum, rval;
    //float *B_h, *B_d;///////////////////////////////////
    int numvar;
    size_t A_sz;//, B_sz;/////////////////////////
    
   

   
    if (argc == 1) {
        matArow = 1000;
        numvar = matArow;
        matAcol = matArow+1;
    } else if (argc == 2) {
        matArow = atoi(argv[1]);
        numvar = matArow;
        matAcol = matArow+1;
    } else {
        printf("\n    Invalid input parameters!"
      "\n    Usage: ./g-elim                # All matrices are 1000 x 1000"
      "\n    Usage: ./g-elim <m>            # All matrices are m x m"
     
      "\n");
        exit(0);
    }

    
    A_sz = matArow*matAcol;
    //B_sz = A_sz;///////////////////////////////////

    A_h = (float*) malloc( sizeof(float)*A_sz );
    for (unsigned int i = 0; i < matArow; i++) { 
        for(unsigned int j = 0; j < matAcol; j++){
        
            A_h[i*matAcol+j] = (rand()%100);
            //printf("%.2f   ", A_h[i*matAcol+j]);
        }
        //printf("\n");
    }
    //printf("\n\n");
        
    //B_h = (float*)malloc(sizeof(float)*B_sz);////////////////////
    //for(unsigned int i = 0; i<B_sz; i++){
        //B_h[i] = 1;
        //printf("%.2f ", B_h[i]);
    //}////////////////////////////////////////////
    //printf("\n");
    
    result = (float*)malloc(sizeof(float)*numvar);

    stopTime(&timer); printf("%f s\n", elapsedTime(timer));
    printf("    A: %u x %u\n    B: %u x %u\n", matArow, matAcol,
        matArow, matAcol);

    // Allocate device variables ----------------------------------------------

    printf("Allocating device variables..."); fflush(stdout);
    startTime(&timer);

    //INSERT CODE HERE
    cuda_ret = cudaMalloc((void**) &A_d, A_sz*sizeof(float));
    if(cuda_ret != cudaSuccess) FATAL("Unable to allocate device memory");

    //cuda_ret = cudaMalloc((void**) &B_d, B_sz*sizeof(float));///////////////////////////
    //if(cuda_ret != cudaSuccess) FATAL("Unable to allocate device memory");//////////////

  

    cudaDeviceSynchronize();
    stopTime(&timer); printf("%f s\n", elapsedTime(timer));

    // Copy host variables to device ------------------------------------------

    printf("Copying data from host to device..."); fflush(stdout);
    startTime(&timer);

    //INSERT CODE HERE
    cudaMemcpy(A_d,A_h,A_sz*sizeof(float),cudaMemcpyHostToDevice);
  
    cudaDeviceSynchronize();
    stopTime(&timer); printf("%f s\n", elapsedTime(timer));
    
    // Launch kernel using standard Gelim interface ---------------------------
    printf("Launching kernel..."); fflush(stdout);
    startTime(&timer);
    
    //basicGelim(A_d,B_d,numvar);//////////////////////////
    basicGelim(A_d,numvar);

    cuda_ret = cudaDeviceSynchronize();
	if(cuda_ret != cudaSuccess) FATAL("Unable to launch kernel");
    stopTime(&timer); printf("%f s\n", elapsedTime(timer));

    printf("Copying data from device to host...\n"); fflush(stdout);
    startTime(&timer);

    cudaMemcpy(A_h,A_d,A_sz*sizeof(float),cudaMemcpyDeviceToHost);//should be all b////////
    
    cudaDeviceSynchronize();
    stopTime(&timer); printf("%f s\n", elapsedTime(timer));

    // Prints U matrix

    /*for(int i = 0; i < numvar; i++){
        for(int j = 0; j< numvar+1; j++){
            printf("%.2f    ", A_h[i*(numvar+1)+j]);///////////////Ah with Bh
        }
        printf("\n");
    }*/////////////////////////////////////comment out section  again


    printf("Backwards Substitution..."); fflush(stdout);
    startTime(&timer);

    // BACKWARDS SUBSTITUTION
    //result = (float*)malloc(sizeof(float)*numvar);
    for(int i = 0; i < numvar; i++){
        result[i] = 1.0;
    }

    for(int i = numvar-1; i >= 0; i--){
        sum = 0;
        int j;
        for(j = numvar-1; j > i; j--){
            sum += result[j]*A_h[i*(numvar+1) + j];///////////////////b instead of a
        }
        rval = A_h[i*(numvar+1) + numvar] - sum;////////////instead
        result[i] = rval/A_h[i*(numvar+1)+j];////////////////instead
       // printf("%.2f\n", resulti[i]);
    }

    stopTime(&timer);
    printf("%f s\n", elapsedTime(timer));
    // Prints solution vector
    /*printf("Printing Results...\n");
    for(int i =0; i < numvar; i++){
        printf("%.6f\n", result[i]);
    }*/


    // Verify correctness -----------------------------------------------------

    printf("Verifying results...\n"); fflush(stdout);

    verify(A_h, result, numvar);///////////////////////////fix this


    // Free memory ------------------------------------------------------------

    free(A_h);
    //free(B_h);/////////////////////////////////////
   

    //INSERT CODE HERE
    cudaFree(A_d);
    //cudaFree(B_d);/////////////////////////
    
    //stopTime(&runtimer);
    //printf("%f s\n", elapsedTime(runtimer));
    return 0;

}
