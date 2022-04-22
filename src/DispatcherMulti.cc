#include "MultiJob_m.h"
#include "DispatcherMulti.h"

namespace fog {

Define_Module(DispatcherMulti);

void DispatcherMulti::initialize() {
}

void DispatcherMulti::handleMessage(cMessage *msg) {
    MultiJob *job = check_and_cast<MultiJob *>(msg);
    // TODO: to implement
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

void DispatcherMulti::finish() {
}

}; //namespace
