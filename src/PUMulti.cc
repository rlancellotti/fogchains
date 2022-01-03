//
// This file is part of an OMNeT++/OMNEST simulation example.
//
// Copyright (C) 2006-2015 OpenSim Ltd.
//
// This file is distributed WITHOUT ANY WARRANTY. See the file
// `license' for details on this and other legal matters.
//

#include "PUMulti.h"

namespace fog {

Define_Module(PUMulti);

PUMulti::PUMulti()
{
    jobServiced = nullptr;
    endServiceMsg = nullptr;
    timeoutMsg = nullptr;
}

PUMulti::~PUMulti()
{
    delete jobServiced;
    cancelAndDelete(endServiceMsg);
    cancelAndDelete(timeoutMsg);
}

void PUMulti::initialize()
{
    droppedSignal = registerSignal("dropped");
    queueingTimeSignal = registerSignal("queueingTime");
    queueLengthSignal = registerSignal("queueLength");
    emit(queueLengthSignal, 0);
    busySignal = registerSignal("busy");
    emit(busySignal, false);
    speedup=par("speedup");
    endServiceMsg = new cMessage("end-service");
    timeoutMsg = new cMessage("timeout");
    capacity = par("capacity");
    queue.setName("queue");
}

void PUMulti::handleMessage(cMessage *msg)
{
    // End Service or Timeout
    if (msg == endServiceMsg || msg == timeoutMsg) {
        if (msg == endServiceMsg){
            endService(jobServiced);
        } else if (msg == endServiceMsg){
            abortService(jobServiced);
        }
        if (queue.isEmpty()) {
            jobServiced = nullptr;
            emit(busySignal, false);
        }
        else {
            jobServiced = getFromQueue();
            emit(queueLengthSignal, length());
            startService(jobServiced);
        }
        return;
    }
    // New job
    MultiJob *job = check_and_cast<MultiJob *>(msg);
    arrival(job);
    if (!jobServiced) {
        // processor was idle
        jobServiced = job;
        emit(busySignal, true);
        startService(jobServiced);
    }
    else {
        // check for container capacity
        if (capacity >= 0 && queue.getLength() >= capacity) {
            EV << "Capacity full! Job dropped.\n";
            if (hasGUI())
                bubble("Dropped!");
            emit(droppedSignal, 1);
            delete job;
            return;
        }
        queue.insert(job);
        emit(queueLengthSignal, length());
        job->setQueueCount(job->getQueueCount() + 1);
    }
}

void PUMulti::refreshDisplay() const
{
    getDisplayString().setTagArg("i2", 0, jobServiced ? "status/execute" : "");
    getDisplayString().setTagArg("i", 1, queue.isEmpty() ? "" : "cyan");
}

MultiJob *PUMulti::getFromQueue()
{
    return (MultiJob *)queue.pop();
}

int PUMulti::length()
{
    return queue.getLength();
}

void PUMulti::arrival(MultiJob *job)
{
    job->setTimestamp();
}

void PUMulti::startService(MultiJob *job)
{
    // gather queueing time statistics
    simtime_t d = simTime() - job->getTimestamp();
    emit(queueingTimeSignal, d);
    job->setQueuingTime(job->getQueuingTime() + d);
    EV << "Starting service of " << job->getName() << endl;
    job->setTimestamp();
    // get service time
    int nservice=job->getServiceCount();
    simtime_t serviceTime=job->getSuggestedTime(nservice);
    scheduleAt(simTime()+serviceTime, endServiceMsg);
    if (job->getSlaDeadline()>0){
        scheduleAt(job->getSlaDeadline(), timeoutMsg);
    }
}

void PUMulti::endService(MultiJob *job)
{
    EV << "Finishing service of " << job->getName() << endl;
    simtime_t d = simTime() - job->getTimestamp();
    job->setServiceTime(job->getServiceTime() + d);
    cancelEvent(timeoutMsg);
    send(job, "out");
}

void PUMulti::abortService(MultiJob *job)
{
    EV << "Timout for " << job->getName() << endl;
    if (hasGUI())
        bubble("Dropped!");
    emit(droppedSignal, 1);
    cancelEvent(endServiceMsg);
    delete job;
}


void PUMulti::finish()
{
}

}; //namespace

