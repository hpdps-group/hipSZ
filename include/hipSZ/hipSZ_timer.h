#ifndef HIPSZ_INCLUDE_HIPSZ_HIPSZ_TIMER_H
#define HIPSZ_INCLUDE_HIPSZ_HIPSZ_TIMER_H

#include <hip/hip_runtime.h>
#include <hip/hip_runtime.h>

struct PrivateTimingGPU {
    hipEvent_t start;
    hipEvent_t stop;
};

class TimingGPU
{
    private:
        PrivateTimingGPU *privateTimingGPU;

    public:
        TimingGPU();
        ~TimingGPU();
        void StartCounter();
        void StartCounterFlags();
        float GetCounter();

};

#endif // HIPSZ_INCLUDE_HIPSZ_HIPSZ_TIMER_H