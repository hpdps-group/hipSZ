#ifndef HIPSZ_H
#define HIPSZ_H

#include <hip/hip_runtime.h>
#include <cstddef>
#include "hipSZ/hipSZ_utility.h"
#include "hipSZ/hipSZ_timer.h"
#include "hipSZ/hipSZ_entry_f32.h"
#include "hipSZ/hipSZ_entry_f64.h"
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    HIPSZ_MODE_PLAIN   = 0, // Plain   fixed-length encoding mode
    HIPSZ_MODE_OUTLIER = 1  // Outlier fixed-length encoding mode
} hipsz_mode_t;

typedef enum {
    HIPSZ_TYPE_FLOAT  = 0,  // Single precision floating point (f32)
    HIPSZ_TYPE_DOUBLE = 1   // Double precision floating point (f64)
} hipsz_type_t;

void hipSZ_compress(void* d_oriData, unsigned char* d_cmpBytes, size_t nbEle, size_t* cmpSize, float errorBound, hipsz_type_t type, hipsz_mode_t mode, hipStream_t stream = 0);
void hipSZ_decompress(void* d_decData, unsigned char* d_cmpBytes, size_t nbEle, size_t cmpSize, float errorBound, hipsz_type_t type, hipsz_mode_t mode, hipStream_t stream = 0);

#ifdef __cplusplus
}
#endif

#endif // HIPSZ_H
