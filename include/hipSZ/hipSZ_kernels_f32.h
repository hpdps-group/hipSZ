#include "hip/hip_runtime.h"
#ifndef HIPSZ_INCLUDE_HIPSZ_HIPSZ_KERNELS_F32_H
#define HIPSZ_INCLUDE_HIPSZ_HIPSZ_KERNELS_F32_H

static const int cmp_tblock_size = 32; // Fixed to 32, cannot be modified.
static const int dec_tblock_size = 32; // Fixed to 32, cannot be modified.
static const int cmp_chunk = 1024;
static const int dec_chunk = 1024;

__global__ void hipSZ_compress_kernel_outlier_f32(const float* const __restrict__ oriData, unsigned char* const __restrict__ cmpData, volatile unsigned int* const __restrict__ cmpOffset, volatile unsigned int* const __restrict__ locOffset, volatile int* const __restrict__ flag, const float eb, const size_t nbEle);
__global__ void hipSZ_decompress_kernel_outlier_f32(float* const __restrict__ decData, const unsigned char* const __restrict__ cmpData, volatile unsigned int* const __restrict__ cmpOffset, volatile unsigned int* const __restrict__ locOffset, volatile int* const __restrict__ flag, const float eb, const size_t nbEle);
__global__ void hipSZ_compress_kernel_plain_f32(const float* const __restrict__ oriData, unsigned char* const __restrict__ cmpData, volatile unsigned int* const __restrict__ cmpOffset, volatile unsigned int* const __restrict__ locOffset, volatile int* const __restrict__ flag, const float eb, const size_t nbEle);
__global__ void hipSZ_decompress_kernel_plain_f32(float* const __restrict__ decData, const unsigned char* const __restrict__ cmpData, volatile unsigned int* const __restrict__ cmpOffset, volatile unsigned int* const __restrict__ locOffset, volatile int* const __restrict__ flag, const float eb, const size_t nbEle);


#endif // HIPSZ_INCLUDE_HIPSZ_HIPSZ_KERNELS_F32_H