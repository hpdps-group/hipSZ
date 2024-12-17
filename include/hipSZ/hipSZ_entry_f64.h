#ifndef HIPSZ_INCLUDE_HIPSZ_HIPSZ_ENTRY_F64_H
#define HIPSZ_INCLUDE_HIPSZ_HIPSZ_ENTRY_F64_H

#include <hip/hip_runtime.h>

void hipSZ_compress_plain_f64(double* d_oriData, unsigned char* d_cmpBytes, size_t nbEle, size_t* cmpSize, double errorBound, hipStream_t stream = 0);
void hipSZ_decompress_plain_f64(double* d_decData, unsigned char* d_cmpBytes, size_t nbEle, size_t cmpSize, double errorBound, hipStream_t stream = 0);
void hipSZ_compress_outlier_f64(double* d_oriData, unsigned char* d_cmpBytes, size_t nbEle, size_t* cmpSize, double errorBound, hipStream_t stream = 0);
void hipSZ_decompress_outlier_f64(double* d_decData, unsigned char* d_cmpBytes, size_t nbEle, size_t cmpSize, double errorBound, hipStream_t stream = 0);

#endif // HIPSZ_INCLUDE_HIPSZ_HIPSZ_ENTRY_F64_H