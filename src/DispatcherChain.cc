#include "ChainJob_m.h"
#include "DispatcherChain.h"

namespace fog {

Define_Module(DispatcherChain);

void DispatcherChain::initialize() {
}

void DispatcherChain::handleMessage(cMessage *msg) {
    ChainJob *job = check_and_cast<ChainJob *>(msg);
    // check if job must exit
    float exitProbability=job->getExitProbability(job->getServiceCount());
    if (uniform(0.0,1.0)< exitProbability){
            job->setLastService(job->getServiceCount());
            send(job, "sinkout");
    } else {
        // Get output port
        int outGateIndex=job->getOutputs(job->getServiceCount());
        // Increment service counter
        job->setServiceCount(job->getServiceCount()+1);
        // send job
        if (outGateIndex<0){
            send(job, "sinkout");
        } else {
            send(job, "out", outGateIndex);
        }
    }
}

void DispatcherChain::finish() {
}

}; //namespace

