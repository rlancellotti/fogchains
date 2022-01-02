#include "MultiJob_m.h"
#include "MultiSink.h"

namespace fog {

Define_Module(MultiSink);

void MultiSink::initialize()
{
    responseTimeSignal = registerSignal("responseTime");
    totalQueueingTimeSignal = registerSignal("totalQueueingTime");
    queuesVisitedSignal = registerSignal("queuesVisited");
    totalServiceTimeSignal = registerSignal("totalServiceTime");
    totalDelayTimeSignal = registerSignal("totalDelayTime");
    delaysVisitedSignal = registerSignal("delaysVisited");

    //generationSignal = registerSignal("generation");
    //keepJobs = par("keepJobs");
}

void MultiSink::handleMessage(cMessage *msg)
{
    MultiJob *job = check_and_cast<MultiJob *>(msg);

    // gather statistics
    emit(responseTimeSignal, simTime()- job->getCreationTime());
    emit(totalQueueingTimeSignal, job->getQueuingTime());
    emit(queuesVisitedSignal, job->getQueueCount());
    emit(totalServiceTimeSignal, job->getServiceTime());
    emit(totalDelayTimeSignal, job->getDelayTime());
    emit(delaysVisitedSignal, job->getDelayCount());
    delete msg;
}

void MultiSink::finish()
{
    // TODO missing scalar statistics
}

}; //namespace

