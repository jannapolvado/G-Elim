/******************************************************************************
 *cr
 *cr            (C) Copyright 2010 The Board of Trustees of the
 *cr                        University of Illinois
 *cr                         All Rights Reserved
 *cr
 ******************************************************************************/

#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

#include "support.h"

void verify(float *A,  float *result, int numvar) {//B before result/////////

  const float relativeTolerance = 1e-4;
  

    printf("\n");
    float *B_c = (float*)malloc(sizeof(float)*numvar*(numvar+1));
    float *result_c = (float*)malloc(sizeof(float)*numvar);

    for(int i = 0; i < numvar*(numvar+1); i++){
        B_c[i] = A[i];
    }  

    for(int i = 0; i < numvar-1; i++){
        for(int j = i+1; j < numvar; j++){
            float multiplier = B_c[j*(numvar+1)+i]/B_c[i*(numvar+1)+i];
            for(int k = i; k < numvar+1; k++){
                B_c[j*(numvar+1)+k] -= (multiplier*B_c[i*(numvar+1)+k]);
                //B_c[j*(numvar+1)+k] = A[j*(numvar+1)+k];
                //printf("%.4f\t", B_c[j*(numvar+1)+k]);
            }
            
            //printf("\n");
        }
    }

    //Initialize result vector
    for(int i =0; i < numvar; i++){
        result_c[i] = 1.0;
    }
    for(int i = numvar-1; i >= 0; i--){
        float sum = 0; 
        int j;
        for(j = numvar-1; j > i; j--){
            sum += (result_c[j]*B_c[i*(numvar+1)+j]);
        }
        float rval = B_c[i*(numvar+1) + numvar] - sum;
        result_c[i] = rval/B_c[i*(numvar+1)+j];
        //printf("%.6f\n", result_c[i]);
    }

    for(int i = 0; i < numvar; i++){
        float relativeError = (result_c[i] - result[i])/result_c[i];
        //printf("result_c: %f\tresult: %f\n", result_c[i], result[i]);
        if(relativeError < -relativeTolerance || relativeError > relativeTolerance){
            printf("TEST FAILED at index  %d \n", i);
            exit(0);
        }
    }
    printf("TEST PASSED\n");

}

void startTime(Timer* timer) {
    gettimeofday(&(timer->startTime), NULL);
}

void stopTime(Timer* timer) {
    gettimeofday(&(timer->endTime), NULL);
}

float elapsedTime(Timer timer) {
    return ((float) ((timer.endTime.tv_sec - timer.startTime.tv_sec) \
                + (timer.endTime.tv_usec - timer.startTime.tv_usec)/1.0e6));
}

