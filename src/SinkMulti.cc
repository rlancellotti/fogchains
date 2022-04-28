#include "MultiJob_m.h"
#include "SinkMulti.h"

namespace fog {

Define_Module(SinkMulti);

void SinkMulti::initialize()
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

void SinkMulti::handleMessage(cMessage *msg)
{
    MultiJob *job = check_and_cast<MultiJob *>(msg);

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

void SinkMulti::finish()
{
    // TODO missing scalar statistics
}

}; //namespace

