//
// This file is part of an OMNeT++/OMNEST simulation example.
//
// Copyright (C) 2006-2015 OpenSim Ltd.
//
// This file is distributed WITHOUT ANY WARRANTY. See the file
// `license' for details on this and other legal matters.
//

#include "DelayChain.h"
#include "ChainJob_m.h"

namespace fog {

Define_Module(DelayChain);

void DelayChain::initialize()
{
    currentlyStored = 0;
    delayedJobsSignal = registerSignal("delayedJobs");
    emit(delayedJobsSignal, 0);
    WATCH(currentlyStored);
}

void DelayChain::handleMessage(cMessage *msg)
{
    ChainJob *job = check_and_cast<ChainJob *>(msg);

    if (!job->isSelfMessage()) {
        // if it is not a self-message, send it to ourselves with a delay
        currentlyStored++;
        double delay = par("delay");
        scheduleAt(simTime() + delay, job);
    }
    else {
        job->setDelayCount(job->getDelayCount()+1);
        simtime_t d = simTime() - job->getSendingTime();
        job->setDelayTime(job->getDelayTime() + d);

        // if it was a self message (ie. we have already delayed) so we send it out
        currentlyStored--;
        send(job, "out");
    }
    emit(delayedJobsSignal, currentlyStored);

}

void DelayChain::refreshDisplay() const
{
    getDisplayString().setTagArg("i", 1, currentlyStored == 0 ? "" : "cyan");
}


}; //namespace

