#include "hipSZ_timer.h"

/** ************************************************************************
 * @brief           HIP event timer for measuring GPU kernel execution.
 * *********************************************************************** */
TimingGPU::TimingGPU() { privateTimingGPU = new PrivateTimingGPU;  }
TimingGPU::~TimingGPU() { }

/** ************************************************************************
 * @brief           Start timer.
 * *********************************************************************** */
void TimingGPU::StartCounter()
{
    hipEventCreate(&((*privateTimingGPU).start));
    hipEventCreate(&((*privateTimingGPU).stop));
    hipEventRecord((*privateTimingGPU).start,0);
}

/** ************************************************************************
 * @brief           Start timer with flags.
 * *********************************************************************** */
void TimingGPU::StartCounterFlags()
{
    int eventflags = hipEventBlockingSync;

    hipEventCreateWithFlags(&((*privateTimingGPU).start),eventflags);
    hipEventCreateWithFlags(&((*privateTimingGPU).stop),eventflags);
    hipEventRecord((*privateTimingGPU).start,0);
}

/** ************************************************************************
 * @brief           End timer, get count in ms.
 * *********************************************************************** */
float TimingGPU::GetCounter()
{
    float time;
    hipEventRecord((*privateTimingGPU).stop, 0);
    hipEventSynchronize((*privateTimingGPU).stop);
    hipEventElapsedTime(&time,(*privateTimingGPU).start,(*privateTimingGPU).stop);
    return time;
}
