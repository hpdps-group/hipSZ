#include "hipSZ.h"

// Wrap-up API for hipSZ compression.
void hipSZ_compress(void* d_oriData, unsigned char* d_cmpBytes, size_t nbEle, size_t* cmpSize, float errorBound, hipsz_type_t type, hipsz_mode_t mode, hipStream_t stream)
{
    if (type == HIPSZ_TYPE_FLOAT) {
        if (mode == HIPSZ_MODE_PLAIN) {
            hipSZ_compress_plain_f32((float*)d_oriData, d_cmpBytes, nbEle, cmpSize, errorBound, stream);
        } 
        else if (mode == HIPSZ_MODE_OUTLIER) {
            hipSZ_compress_outlier_f32((float*)d_oriData, d_cmpBytes, nbEle, cmpSize, errorBound, stream);
        }
        else {
            printf("Unsupported mode in hipSZ.\n");
        }
    } 
    else if (type == HIPSZ_TYPE_DOUBLE) {
        double errorBound_f64 = (double)errorBound;
        if (mode == HIPSZ_MODE_PLAIN) {
            hipSZ_compress_plain_f64((double*)d_oriData, d_cmpBytes, nbEle, cmpSize, errorBound_f64, stream);
        } 
        else if (mode == HIPSZ_MODE_OUTLIER) {
            hipSZ_compress_outlier_f64((double*)d_oriData, d_cmpBytes, nbEle, cmpSize, errorBound_f64, stream);
        }
        else{
            printf("Unsupported mode in hipSZ.\n");
        }
    }
    else {
        printf("Unsupported type in hipSZ.\n");
    }
}

// Wrap-up API for hipSZ decompression.
void hipSZ_decompress(void* d_decData, unsigned char* d_cmpBytes, size_t nbEle, size_t cmpSize, float errorBound, hipsz_type_t type, hipsz_mode_t mode, hipStream_t stream)
{
    if (type == HIPSZ_TYPE_FLOAT) {
        if (mode == HIPSZ_MODE_PLAIN) {
            hipSZ_decompress_plain_f32((float*)d_decData, d_cmpBytes, nbEle, cmpSize, errorBound, stream);
        } 
        else if (mode == HIPSZ_MODE_OUTLIER) {
            hipSZ_decompress_outlier_f32((float*)d_decData, d_cmpBytes, nbEle, cmpSize, errorBound, stream);
        }
        else {
            printf("Unsupported mode in hipSZ.\n");
        }
    } 
    else if (type == HIPSZ_TYPE_DOUBLE) {
        double errorBound_f64 = (double)errorBound;
        if (mode == HIPSZ_MODE_PLAIN) {
            hipSZ_decompress_plain_f64((double*)d_decData, d_cmpBytes, nbEle, cmpSize, errorBound_f64, stream);
        } 
        else if (mode == HIPSZ_MODE_OUTLIER) {
            hipSZ_decompress_outlier_f64((double*)d_decData, d_cmpBytes, nbEle, cmpSize, errorBound_f64, stream);
        }
        else {
            printf("Unsupported mode in hipSZ.\n");
        }
    }
    else {
        printf("Unsupported type in hipSZ.\n");
    }
}