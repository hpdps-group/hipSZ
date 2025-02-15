<h1 align="center">
A HIP-Based Error-Bounded Lossy Compressor for Scientific Data
</h1>

<p align="center">
<a href="./LICENSE"><img src="https://img.shields.io/badge/License-BSD%203--Clause-blue.svg"></a>
</p>

hipSZ is a [HIP](https://github.com/ROCm/HIP) implementation of the widely used [SZ](https://szcompressor.org/) lossy compression framework for scientific data, specifically based on the [cuSZp](https://github.com/szcompressor/cuSZp) algorithm. It is the *first* error-bounded lossy compressor that can run on mainstream HPC/AI accelerators including Nvidia GPUs, AMD GPUs, and Hygon DCUs via [ROCm](https://www.amd.com/en/products/software/rocm.html) platform. 

(C) 2024 by Chinese Academy of Sciences and University of Science and Technology of China. See [COPYRIGHT](https://github.com/szcompressor/hipSZ/blob/master/LICENSE) in top-level directory.

- Developers: Shengquan Yin, [Dingwen Tao](https://www.dingwentao.com/) (advisor), [Guangming Tan](https://tanniu.github.io/) (advisor)

## Environment Requirements
- Linux OS with AMD GPU or Hygon DCU
- Git >= 2.15
- CMake >= 3.21
- ROCm >= 6.2 or DCU Toolkit >= 24.04.1
- clang >= 15.0.0
- CUDA Toolkit（TODO）

## Compile and Use hipSZ

You can compile and install hipSZ with following commands.
```shell
$ git clone https://github.com/szcompressor/hipSZ.git
$ cd hipSZ
$ mkdir build && cd build
$ cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../install/ ..
$ make -j
$ make install
```
After installation, you will see executable binary generated in ```hipSZ/install/bin/``` and shared/static library generated in ``hipSZ/install/lib/``.
You can also try ```ctest -V``` in ```hipSZ/build/``` folder (Optional).

### Using hipSZ Prepared Executable Binary
After installation, you will see ```hipSZ``` binary generated in ```hipSZ/install/bin/```. The detailed usage of this binary are explained in the code block below.

```text
Usage:
./hipSZ -i [oriFilePath] -t [dataType] 
        -m [encodingMode] -eb [errorBoundMode] [errorBound] 
        -x [cmpFilePath] -o [decFilePath]

Options:
  -i  [oriFilePath]    Path to the input file containing the original data
  -t  [dataType]       Data type of the input data. Options:
                       f32      : Single precision (float)
                       f64      : Double precision (double)
  -m  [encodingMode]   Encoding mode to use. Options:
                       plain    : Plain fixed-length encoding mode
                       outlier  : Outlier fixed-length encoding mode
  -eb [errorBoundMode] [errorBound]
                       errorBoundMode can only be:
                       abs      : Absolute error bound
                       rel      : Relative error bound
                       errorBound is a floating-point number representing the error bound, e.g. 1E-4, 0.03.
  -x  [cmpFilePath]    Path to the compressed output file (optional)
  -o  [decFilePath]    Path to the decompressed output file (optional)
```

Some example commands can be found here:
```shell
./hipSZ -i CLDLIQ_1_26_1800_3600.f32 -t f32 -m plain -eb rel 1e-4
./hipSZ -i CLDLIQ_1_26_1800_3600.f32 -t f32 -m outlier -eb rel 1e-4
```

Some results measured on one Hygon K100 DCU can be shown as below:
```shell
$ ./hipSZ -i CLDLIQ_1_26_1800_3600.f32 -t f32 -m plain -eb rel 1e-4
hipSZ finished!
hipSZ compression   end-to-end speed: 135.495201 GB/s
hipSZ decompression end-to-end speed: 272.553248 GB/s
hipSZ compression ratio: 9.897107

Pass error check!

$ ./hipSZ -i CLDLIQ_1_26_1800_3600.f32 -t f32 -m outlier -eb rel 1e-4 
hipSZ finished!
hipSZ compression   end-to-end speed: 65.323701 GB/s
hipSZ decompression end-to-end speed: 182.146842 GB/s
hipSZ compression ratio: 17.361573

Pass error check!
```

You will also see two binaries generated this folder, named ```hipSZ_test_f32``` and ```hipSZ_test_f64```. They are used for functionality test and can be executed by ```./hipSZ_test_f32``` and ```./hipSZ_test_f64```.

### Using hipSZ as C/C++ Interal API
If you want to use hipSZ as a C/C++ interal API, there are two ways.

1. Use the hipSZ generic API.
    
    ```C
    // Other headers.
    #include <hipSZ.h>
    
    int main (int argc, char* argv[]) {
        
        // Other code.

        // For measuring the end-to-end throughput.
        TimingGPU timer_GPU;

        // hipSZ compression for device pointer.
        timer_GPU.StartCounter(); // set timer
        hipSZ_compress(d_oriData, d_cmpBytes, nbEle, &cmpSize, errorBound, dataType, encodingMode, stream);
        float cmpTime = timer_GPU.GetCounter();

        // hipSZ decompression for device pointer.
        timer_GPU.StartCounter(); // set timer
        hipSZ_decompress(d_decData, d_cmpBytes, nbEle, cmpSize, errorBound, dataType, encodingMode, stream);
        float decTime = timer_GPU.GetCounter();

        // Other code.

        return 0;
    }
    ```

    Here, ```d_oriData```, ```d_cmpBytes```, and ```d_decData``` are device pointers (array on GPU), representing original data, compressed byte, and reconstructed data, respectively.
    ```dataType``` and ```encodingMode``` can be defined as below:
    ```C
    hipsz_type_t dataType = HIPSZ_TYPE_FLOAT; // or HIPSZ_TYPE_DOUBLE
    hipsz_mode_t encodingMode = HIPSZ_MODE_PLAIN; // or HIPSZ_MODE_OUTLIER
    ```

    A detailed example can be seen in ```hipSZ/examples/hipSZ.cpp```.

2. Use a specific encoding mode and floating-point data type (f32 or f64).

    ```C
    #include <hipSZ.h> // Still the only header you need.

    // Compression and decompression for float type data array using plain mode.
    hipSZ_compress_plain_f32(d_oriData, d_cmpBytes, nbEle, &cmpSize, errorBound, stream);
    hipSZ_decompress_plain_f32(d_decData, d_cmpBytes, nbEle, cmpSize, errorBound, stream);
    // In this case, d_oriData and d_Decdata are float* array on GPU.
    ```
    
    <details>
    <summary>Other modes and data type usages</summary>

    ```C
    #include <hipSZ.h> // Still the only header you need.

    // Compression and decompression for float type data array using outlier mode.
    hipSZ_compress_outlier_f32(d_oriData, d_cmpBytes, nbEle, &cmpSize, errorBound, stream);
    hipSZ_decompress_outlier_f32(d_decData, d_cmpBytes, nbEle, cmpSize, errorBound, stream);
    // In this case, d_oriData and d_Decdata are float* array on GPU.

    // Compression and decompression for double type data array using plain mode.
    hipSZ_compress_plain_f64(d_oriData, d_cmpBytes, nbEle, &cmpSize, errorBound, stream);
    hipSZ_decompress_plain_f64(d_decData, d_cmpBytes, nbEle, cmpSize, errorBound, stream);
    // In this case, d_oriData and d_Decdata are double* array on GPU.

    // Compression and decompression for double type data array using outlier mode.
    hipSZ_compress_outlier_f64(d_oriData, d_cmpBytes, nbEle, &cmpSize, errorBound, stream);
    hipSZ_decompress_outlier_f64(d_decData, d_cmpBytes, nbEle, cmpSize, errorBound, stream);
    // In this case, d_oriData and d_Decdata are double* array on GPU.
    ```
    </details>

    
    In this case, you do not need to set ```hipsz_type_t``` and ```hipsz_mode_t```.
    More detaild examples can be found in ```hipSZ/examples/hipSZ_test_f32.cpp``` and ```hipSZ/examples/hipSZ_test_f64.cpp```.


### Using hipSZ as Python API
TODO

## Documentation
TODO

## Citation
TODO

## Clarification
Due to political reasons between China and the U.S., the development of hipSZ is independent of other software and repositories under github.com/szcompressor. There is no administrative, legal connection, or collaboration between the developers of hipSZ and the U.S. developers of szcompressor software.
