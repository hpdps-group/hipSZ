#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>
#include <hip/hip_runtime.h>
#include <hipSZ.h>

int main()
{
    // For measuring the end-to-end throughput.
    TimingGPU timer_GPU;

    // Input data preparation on CPU.
    double* oriData = NULL;
    double* decData = NULL;
    unsigned char* cmpBytes = NULL;
    size_t nbEle = 1024*1024*512; // 4 GB fp64 data.
    size_t cmpSize1 = 0;
    size_t cmpSize2 = 0;
    oriData = (double*)malloc(nbEle*sizeof(double));
    decData = (double*)malloc(nbEle*sizeof(double));
    cmpBytes = (unsigned char*)malloc(nbEle*sizeof(double));

    // Initialize oriData.
    printf("Generating test data...\n\n");
    double startValue = -20.0f;
    double step = 0.1f;
    double endValue = 20.0f;
    size_t idx = 0;
    double value = startValue;
    while (idx < nbEle) 
    {
        oriData[idx++] = value;
        value += step;
        if (value > endValue)
        {
            value = startValue;
        }
    }

    // Get value range, making it a REL errMode test -- remove this will be ABS errMode.
    double max_val = oriData[0];
    double min_val = oriData[0];
    for(size_t i=0; i<nbEle; i++)
    {
        if(oriData[i]>max_val)
            max_val = oriData[i];
        else if(oriData[i]<min_val)
            min_val = oriData[i];
    }
    double errorBound = (max_val - min_val) * 1E-2f;

    // Input data preparation on GPU.
    double* d_oriData;
    double* d_decData;
    unsigned char* d_cmpBytes;
    hipMalloc((void**)&d_oriData, sizeof(double)*nbEle);
    hipMemcpy(d_oriData, oriData, sizeof(double)*nbEle, hipMemcpyHostToDevice);
    hipMalloc((void**)&d_decData, sizeof(double)*nbEle);
    hipMalloc((void**)&d_cmpBytes, sizeof(double)*nbEle);

    // Initializing HIP Stream.
    hipStream_t stream;
    hipStreamCreate(&stream);

    // Warmup for NVIDIA GPU.
    for(int i=0; i<3; i++)
    {
        hipSZ_compress_plain_f64(d_oriData, d_cmpBytes, nbEle, &cmpSize1, errorBound, stream);
    }

    // hipSZ-p testing.
    printf("=================================================\n");
    printf("=========Testing hipSZ-p-f64 on REL 1E-2=========\n");
    printf("=================================================\n");
    // hipSZ compression.
    timer_GPU.StartCounter(); // set timer
    hipSZ_compress_plain_f64(d_oriData, d_cmpBytes, nbEle, &cmpSize1, errorBound, stream);
    float cmpTime = timer_GPU.GetCounter();

    // Transfer compressed data to CPU then back to GPU, making sure compression ratio is correct.
    // No need to add this part for real-world usages, this is only for testing compresion ratio correcness.
    unsigned char* cmpBytes_dup1 = (unsigned char*)malloc(cmpSize1*sizeof(unsigned char));
    hipMemcpy(cmpBytes_dup1, d_cmpBytes, cmpSize1*sizeof(unsigned char), hipMemcpyDeviceToHost);
    hipMemset(d_cmpBytes, 0, sizeof(double)*nbEle); // set to zero for double check.
    hipMemcpy(d_cmpBytes, cmpBytes_dup1, cmpSize1*sizeof(unsigned char), hipMemcpyHostToDevice);
        
    // hipSZ decompression.
    timer_GPU.StartCounter(); // set timer
    hipSZ_decompress_plain_f64(d_decData, d_cmpBytes, nbEle, cmpSize1, errorBound, stream);
    float decTime = timer_GPU.GetCounter();

    // Print result.
    printf("hipSZ-p finished!\n");
    printf("hipSZ-p compression   end-to-end speed: %f GB/s\n", (nbEle*sizeof(double)/1024.0/1024.0)/cmpTime);
    printf("hipSZ-p decompression end-to-end speed: %f GB/s\n", (nbEle*sizeof(double)/1024.0/1024.0)/decTime);
    printf("hipSZ-p compression ratio: %f\n", (nbEle*sizeof(double)/1024.0/1024.0)/(cmpSize1*sizeof(unsigned char)/1024.0/1024.0));
    
    // Error check
    hipMemcpy(cmpBytes, d_cmpBytes, cmpSize1*sizeof(unsigned char), hipMemcpyDeviceToHost);
    hipMemcpy(decData, d_decData, sizeof(double)*nbEle, hipMemcpyDeviceToHost);
    int not_bound = 0;
    for(size_t i=0; i<nbEle; i++)
    {
        if(fabs(oriData[i]-decData[i]) > errorBound*1.1)
        {
            not_bound++;
            // printf("not bound: %zu oriData: %f, decData: %f, errors: %f, bound: %f\n", i, oriData[i], decData[i], fabs(oriData[i]-decData[i]), errorBound);
        }
    }
    if(!not_bound) printf("\033[0;32mPass error check!\033[0m\n");
    else printf("\033[0;31mFail error check! Exceeding data count: %d\033[0m\n", not_bound);
    printf("\033[1mDone with testing hipSZ-p on REL 1E-2!\033[0m\n\n");

    // hipSZ-o testing.
    printf("=================================================\n");
    printf("=========Testing hipSZ-o-f64 on REL 1E-2=========\n");
    printf("=================================================\n");
    // hipSZ compression.
    timer_GPU.StartCounter(); // set timer
    hipSZ_compress_outlier_f64(d_oriData, d_cmpBytes, nbEle, &cmpSize2, errorBound, stream);
    cmpTime = timer_GPU.GetCounter();

    // Transfer compressed data to CPU then back to GPU, making sure compression ratio is correct.
    // No need to add this part for real-world usages, this is only for testing compresion ratio correcness.
    unsigned char* cmpBytes_dup2 = (unsigned char*)malloc(cmpSize2*sizeof(unsigned char));
    hipMemcpy(cmpBytes_dup2, d_cmpBytes, cmpSize2*sizeof(unsigned char), hipMemcpyDeviceToHost);
    hipMemset(d_cmpBytes, 0, sizeof(double)*nbEle); // set to zero for double check.
    hipMemcpy(d_cmpBytes, cmpBytes_dup2, cmpSize2*sizeof(unsigned char), hipMemcpyHostToDevice);
        
    // hipSZ decompression.
    timer_GPU.StartCounter(); // set timer
    hipSZ_decompress_outlier_f64(d_decData, d_cmpBytes, nbEle, cmpSize2, errorBound, stream);
    decTime = timer_GPU.GetCounter();

    // Print result.
    printf("hipSZ-o finished!\n");
    printf("hipSZ-o compression   end-to-end speed: %f GB/s\n", (nbEle*sizeof(double)/1024.0/1024.0)/cmpTime);
    printf("hipSZ-o decompression end-to-end speed: %f GB/s\n", (nbEle*sizeof(double)/1024.0/1024.0)/decTime);
    printf("hipSZ-o compression ratio: %f\n", (nbEle*sizeof(double)/1024.0/1024.0)/(cmpSize2*sizeof(unsigned char)/1024.0/1024.0));

    // Error check
    hipMemcpy(cmpBytes, d_cmpBytes, cmpSize2*sizeof(unsigned char), hipMemcpyDeviceToHost);
    hipMemcpy(decData, d_decData, sizeof(double)*nbEle, hipMemcpyDeviceToHost);
    not_bound = 0;
    for(size_t i=0; i<nbEle; i++)
    {
        if(fabs(oriData[i]-decData[i]) > errorBound*1.1)
        {
            not_bound++;
            // printf("not bound: %zu oriData: %f, decData: %f, errors: %f, bound: %f\n", i, oriData[i], decData[i], fabs(oriData[i]-decData[i]), errorBound);
        }
    }
    if(!not_bound) printf("\033[0;32mPass error check!\033[0m\n");
    else printf("\033[0;31mFail error check! Exceeding data count: %d\033[0m\n", not_bound);
    printf("\033[1mDone with testing hipSZ-o on REL 1E-2!\033[0m\n");

    free(oriData);
    free(decData);
    free(cmpBytes);
    free(cmpBytes_dup1);
    free(cmpBytes_dup2);
    hipFree(d_oriData);
    hipFree(d_decData);
    hipFree(d_cmpBytes);
    hipStreamDestroy(stream);

    return 0;
}