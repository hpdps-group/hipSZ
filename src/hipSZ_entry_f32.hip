#include "hipSZ_entry_f32.h"
#include "hipSZ_kernels_f32.h"

/** ************************************************************************
 * @brief hipSZ end-to-end compression API for device pointers
 *        Compression is executed in GPU.
 *        Original data is stored as device pointers (in GPU).
 *        Compressed data is stored back as device pointers (in GPU).
 * 
 * @param   d_oriData       original data (device pointer)
 * @param   d_cmpBytes      compressed data (device pointer)
 * @param   nbEle           original data size (number of floating point)
 * @param   cmpSize         compressed data size (number of unsigned char)
 * @param   errorBound      user-defined error bound
 * @param   stream          HIP stream for executing compression kernel
 * *********************************************************************** */
void hipSZ_compress_plain_f32(float* d_oriData, unsigned char* d_cmpBytes, size_t nbEle, size_t* cmpSize, float errorBound, hipStream_t stream)
{
    // Data blocking.
    int bsize = cmp_tblock_size;
    int gsize = (nbEle + bsize * cmp_chunk - 1) / (bsize * cmp_chunk);
    int cmpOffSize = gsize + 1;

    // Initializing global memory for GPU compression.
    unsigned int* d_cmpOffset;
    unsigned int* d_locOffset;
    int* d_flag;
    unsigned int glob_sync;
    hipMalloc((void**)&d_cmpOffset, sizeof(unsigned int)*cmpOffSize);
    hipMemset(d_cmpOffset, 0, sizeof(unsigned int)*cmpOffSize);
    hipMalloc((void**)&d_locOffset, sizeof(unsigned int)*cmpOffSize);
    hipMemset(d_locOffset, 0, sizeof(unsigned int)*cmpOffSize);
    hipMalloc((void**)&d_flag, sizeof(int)*cmpOffSize);
    hipMemset(d_flag, 0, sizeof(int)*cmpOffSize);

    // hipSZ GPU compression.
    dim3 blockSize(bsize);
    dim3 gridSize(gsize);
    hipSZ_compress_kernel_plain_f32<<<gridSize, blockSize, sizeof(unsigned int)*2, stream>>>(d_oriData, d_cmpBytes, d_cmpOffset, d_locOffset, d_flag, errorBound, nbEle);

    // Obtain compression ratio and move data back to CPU.  
    hipMemcpy(&glob_sync, d_cmpOffset+cmpOffSize-1, sizeof(unsigned int), hipMemcpyDeviceToHost);
    *cmpSize = (size_t)glob_sync + (nbEle+cmp_tblock_size*cmp_chunk-1)/(cmp_tblock_size*cmp_chunk)*(cmp_tblock_size*cmp_chunk)/32;

    // Free memory that is used.
    hipFree(d_cmpOffset);
    hipFree(d_locOffset);
    hipFree(d_flag);
}

 /** ************************************************************************
 * @brief hipSZ end-to-end decompression API for device pointers
 *        Decompression is executed in GPU.
 *        Compressed data is stored as device pointers (in GPU).
 *        Reconstructed data is stored as device pointers (in GPU).
 *        P.S. Reconstructed data and original data have the same shape.
 * 
 * @param   d_decData       reconstructed data (device pointer)
 * @param   d_cmpBytes      compressed data (device pointer)
 * @param   nbEle           reconstructed data size (number of floating point)
 * @param   cmpSize         compressed data size (number of unsigned char)
 * @param   errorBound      user-defined error bound
 * @param   stream          HIP stream for executing compression kernel
 * *********************************************************************** */
void hipSZ_decompress_plain_f32(float* d_decData, unsigned char* d_cmpBytes, size_t nbEle, size_t cmpSize, float errorBound, hipStream_t stream)
{
    // Data blocking.
    int bsize = dec_tblock_size;
    int gsize = (nbEle + bsize * dec_chunk - 1) / (bsize * dec_chunk);
    int cmpOffSize = gsize + 1;

    // Initializing global memory for GPU decompression.
    unsigned int* d_cmpOffset;
    unsigned int* d_locOffset;
    int* d_flag;
    hipMalloc((void**)&d_cmpOffset, sizeof(unsigned int)*cmpOffSize);
    hipMemset(d_cmpOffset, 0, sizeof(unsigned int)*cmpOffSize);
    hipMalloc((void**)&d_locOffset, sizeof(unsigned int)*cmpOffSize);
    hipMemset(d_locOffset, 0, sizeof(unsigned int)*cmpOffSize);
    hipMalloc((void**)&d_flag, sizeof(int)*cmpOffSize);
    hipMemset(d_flag, 0, sizeof(int)*cmpOffSize);

    // hipSZ GPU decompression.
    dim3 blockSize(bsize);
    dim3 gridSize(gsize);
    hipSZ_decompress_kernel_plain_f32<<<gridSize, blockSize, sizeof(unsigned int)*2, stream>>>(d_decData, d_cmpBytes, d_cmpOffset, d_locOffset, d_flag, errorBound, nbEle);
    
    // Free memory that is used.
    hipFree(d_cmpOffset);
    hipFree(d_locOffset);
    hipFree(d_flag);
}

/** ************************************************************************
 * @brief hipSZ end-to-end compression API for device pointers
 *        Compression is executed in GPU.
 *        Original data is stored as device pointers (in GPU).
 *        Compressed data is stored back as device pointers (in GPU).
 * 
 * @param   d_oriData       original data (device pointer)
 * @param   d_cmpBytes      compressed data (device pointer)
 * @param   nbEle           original data size (number of floating point)
 * @param   cmpSize         compressed data size (number of unsigned char)
 * @param   errorBound      user-defined error bound
 * @param   stream          HIP stream for executing compression kernel
 * *********************************************************************** */
void hipSZ_compress_outlier_f32(float* d_oriData, unsigned char* d_cmpBytes, size_t nbEle, size_t* cmpSize, float errorBound, hipStream_t stream)
{
    // Data blocking.
    int bsize = cmp_tblock_size;
    int gsize = (nbEle + bsize * cmp_chunk - 1) / (bsize * cmp_chunk);
    int cmpOffSize = gsize + 1;

    // Initializing global memory for GPU compression.
    unsigned int* d_cmpOffset;
    unsigned int* d_locOffset;
    int* d_flag;
    unsigned int glob_sync;
    hipMalloc((void**)&d_cmpOffset, sizeof(unsigned int)*cmpOffSize);
    hipMemset(d_cmpOffset, 0, sizeof(unsigned int)*cmpOffSize);
    hipMalloc((void**)&d_locOffset, sizeof(unsigned int)*cmpOffSize);
    hipMemset(d_locOffset, 0, sizeof(unsigned int)*cmpOffSize);
    hipMalloc((void**)&d_flag, sizeof(int)*cmpOffSize);
    hipMemset(d_flag, 0, sizeof(int)*cmpOffSize);

    // hipSZ GPU compression.
    dim3 blockSize(bsize);
    dim3 gridSize(gsize);
    hipSZ_compress_kernel_outlier_f32<<<gridSize, blockSize, sizeof(unsigned int)*2, stream>>>(d_oriData, d_cmpBytes, d_cmpOffset, d_locOffset, d_flag, errorBound, nbEle);

    // Obtain compression ratio and move data back to CPU.  
    hipMemcpy(&glob_sync, d_cmpOffset+cmpOffSize-1, sizeof(unsigned int), hipMemcpyDeviceToHost);
    *cmpSize = (size_t)glob_sync + (nbEle+cmp_tblock_size*cmp_chunk-1)/(cmp_tblock_size*cmp_chunk)*(cmp_tblock_size*cmp_chunk)/32;

    // Free memory that is used.
    hipFree(d_cmpOffset);
    hipFree(d_locOffset);
    hipFree(d_flag);
}

 /** ************************************************************************
 * @brief hipSZ end-to-end decompression API for device pointers
 *        Decompression is executed in GPU.
 *        Compressed data is stored as device pointers (in GPU).
 *        Reconstructed data is stored as device pointers (in GPU).
 *        P.S. Reconstructed data and original data have the same shape.
 * 
 * @param   d_decData       reconstructed data (device pointer)
 * @param   d_cmpBytes      compressed data (device pointer)
 * @param   nbEle           reconstructed data size (number of floating point)
 * @param   cmpSize         compressed data size (number of unsigned char)
 * @param   errorBound      user-defined error bound
 * @param   stream          HIP stream for executing compression kernel
 * *********************************************************************** */
void hipSZ_decompress_outlier_f32(float* d_decData, unsigned char* d_cmpBytes, size_t nbEle, size_t cmpSize, float errorBound, hipStream_t stream)
{
    // Data blocking.
    int bsize = dec_tblock_size;
    int gsize = (nbEle + bsize * dec_chunk - 1) / (bsize * dec_chunk);
    int cmpOffSize = gsize + 1;

    // Initializing global memory for GPU decompression.
    unsigned int* d_cmpOffset;
    unsigned int* d_locOffset;
    int* d_flag;
    hipMalloc((void**)&d_cmpOffset, sizeof(unsigned int)*cmpOffSize);
    hipMemset(d_cmpOffset, 0, sizeof(unsigned int)*cmpOffSize);
    hipMalloc((void**)&d_locOffset, sizeof(unsigned int)*cmpOffSize);
    hipMemset(d_locOffset, 0, sizeof(unsigned int)*cmpOffSize);
    hipMalloc((void**)&d_flag, sizeof(int)*cmpOffSize);
    hipMemset(d_flag, 0, sizeof(int)*cmpOffSize);

    // hipSZ GPU decompression.
    dim3 blockSize(bsize);
    dim3 gridSize(gsize);
    hipSZ_decompress_kernel_outlier_f32<<<gridSize, blockSize, sizeof(unsigned int)*2, stream>>>(d_decData, d_cmpBytes, d_cmpOffset, d_locOffset, d_flag, errorBound, nbEle);
    
    // Free memory that is used.
    hipFree(d_cmpOffset);
    hipFree(d_locOffset);
    hipFree(d_flag);
}