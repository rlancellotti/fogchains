#include "ChainJob_m.h"
#include "SinkChain.h"

namespace fog {

Define_Module(SinkChain);

void SinkChain::initialize()
{
    responseTimeSignal = registerSignal("responseTime");
    totalQueueingTimeSignal = registerSignal("totalQueueingTime");
    queuesVisitedSignal = registerSignal("queuesVisited");
    totalServiceTimeSignal = registerSignal("totalServiceTime");
    totalDelayTimeSignal = registerSignal("totalDelayTime");
    delaysVisitedSignal = registerSignal("delaysVisited");
    earlyExit = registerSignal("earlyExit");

    //generationSignal = registerSignal("generation");
    //keepJobs = par("keepJobs");
}

void SinkChain::handleMessage(cMessage *msg)
{
    ChainJob *job = check_and_cast<ChainJob *>(msg);

    // gather statistics
    emit(responseTimeSignal, simTime()- job->getCreationTime());
    emit(totalQueueingTimeSignal, job->getQueuingTime());
    emit(queuesVisitedSignal, job->getQueueCount());
    emit(totalServiceTimeSignal, job->getServiceTime());
    emit(totalDelayTimeSignal, job->getDelayTime());
    emit(delaysVisitedSignal, job->getDelayCount());
    if (job->getLastService()>=0){
        emit (earlyExit, job->getLastService());
    }
    delete msg;
}

void SinkChain::finish()
{
    // TODO missing scalar statistics
}

}; //namespace

