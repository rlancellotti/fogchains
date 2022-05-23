//
// This file is part of an OMNeT++/OMNEST simulation example.
//
// Copyright (C) 2006-2015 OpenSim Ltd.
//
// This file is distributed WITHOUT ANY WARRANTY. See the file
// `license' for details on this and other legal matters.
//

#include "PUChainMCore.h"

namespace fog {

Define_Module(PUChainMCore);

PUChainMCore::PUChainMCore() {
}

PUChainMCore::~PUChainMCore() {
    jobServiced.clear();
    for (int i=0; i<ncores; i++){
        cancelAndDelete(endServiceMsg[i]);
        cancelAndDelete(timeoutMsg[i]);
    }
}

void PUChainMCore::initialize() {
    droppedSignal = registerSignal("dropped");
    queueingTimeSignal = registerSignal("queueingTime");
    queueLengthSignal = registerSignal("queueLength");
    emit(queueLengthSignal, 0);
    busySignal = registerSignal("busy");
    emit(busySignal, 0);
    speedup=par("speedup");
    ncores=par("ncores");
    endServiceMsg.resize(ncores);
    timeoutMsg.resize(ncores);
    busyCore.resize(ncores);
    jobServiced.resize(ncores);
    for (int i=0; i<ncores; i++){
        endServiceMsg[i]=new cMessage("end-service");
        timeoutMsg[i]=new cMessage("timeout");
        busyCore[i]=false;
    }
    lastUsedCore=0;
    capacity = par("capacity");
    queue.setName("queue");
}

int PUChainMCore::isEndServiceMsg(cMessage *msg){
    for (int i=0; i<ncores; i++) {
        if (msg==endServiceMsg[i])
            return i;
    }
    return -1;
}

int PUChainMCore::isTimeoutMsg(cMessage *msg){
    for (int i=0; i<ncores; i++) {
        if (msg==timeoutMsg[i])
            return i;
    }
    return -1;
}

int PUChainMCore::getBusyCores() const {
    int bc=0;
    for (int i=0; i<ncores; i++) {
        if (busyCore[i])
            bc++;
    }
    return bc;
}


int PUChainMCore::getCoreFromJob(ChainJob *job){
    for (int i=0; i<ncores; i++) {
        if (job==jobServiced[i])
            return i;
    }
    return -1;
}

void PUChainMCore::handleMessage(cMessage *msg) {
    // End Service or Timeout
    int endmsg=isEndServiceMsg(msg);
    int tomsg=isTimeoutMsg(msg);
    if (endmsg<0 || tomsg<0) {
        if (endmsg>=0){
            endService(endmsg);
        } else if (tomsg >=0){
            abortService(tomsg);
        }
        if (! queue.isEmpty()) {
            ChainJob* newjob = getFromQueue();
            emit(queueLengthSignal, length());
            startService(newjob);
        }
        return;
    }
    // New job
    ChainJob *job = check_and_cast<ChainJob *>(msg);
    arrival(job);
    if (getBusyCores()<ncores) {
        // there is an idle core
        startService(job);
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

void PUChainMCore::refreshDisplay() const {
    getDisplayString().setTagArg("i2", 0, getBusyCores()>0 ? "status/execute" : "");
    getDisplayString().setTagArg("i", 1, queue.isEmpty() ? "" : "cyan");
}

/*same as superclass, no need to redefine it*/
/*void PUChainMCore::arrival(ChainJob *job) {
    job->setTimestamp();
}*/

void PUChainMCore::startService(ChainJob *job) {
    // gather queueing time statistics
    simtime_t d = simTime() - job->getTimestamp();
    emit(queueingTimeSignal, d);
    job->setQueuingTime(job->getQueuingTime() + d);
    EV << "Starting service of " << job->getName() << endl;
    job->setTimestamp();
    int nservice=job->getServiceCount();
    simtime_t serviceTime=job->getSuggestedTime(nservice)/speedup;
    int core=getBestCore();
    setBusyCore(core);
    jobServiced[core]=job;
    scheduleAt(simTime()+serviceTime, endServiceMsg[core]);
    if (job->getSlaDeadline()>0){
        scheduleAt(job->getSlaDeadline(), timeoutMsg[core]);
    }
}

int PUChainMCore::getBestCore() {
    for (int i=(lastUsedCore+1)%ncores; i!=lastUsedCore; i=(i+1)%ncores){
        if (!busyCore[i]) {
            lastUsedCore=i;
            return i;
        }
    }
    return -1;
}

void PUChainMCore::endService(ChainJob * job) {
    endService(getCoreFromJob(job));
}

void PUChainMCore::endService(int jobCoreID) {
    if (jobCoreID>0)
        return;
    ChainJob *job=jobServiced[jobCoreID];
    EV << "Finishing service of " << job->getName() << endl;
    simtime_t d = simTime() - job->getTimestamp();
    job->setServiceTime(job->getServiceTime() + d);
    cancelEvent(timeoutMsg[jobCoreID]);
    setFreeCore(jobCoreID);
    send(job, "out");
}

void PUChainMCore::abortService(ChainJob * job) {
    abortService(getCoreFromJob(job));
}

void PUChainMCore::abortService(int jobCoreID) {
    if (jobCoreID>0)
        return;
    ChainJob *job=jobServiced[jobCoreID];
    EV << "Timout for " << job->getName() << endl;
    if (hasGUI())
        bubble("Dropped!");
    emit(droppedSignal, 1);
    cancelEvent(endServiceMsg[jobCoreID]);
    setFreeCore(jobCoreID);
    delete job;
}

void PUChainMCore::setCoreStatus(int coreID, bool busy){
    busyCore[coreID]=busy;
    emit(busySignal, getBusyCores());
}

void PUChainMCore::setFreeCore(int coreID) {
    setCoreStatus(coreID, false);
}

void PUChainMCore::setBusyCore(int coreID) {
    setCoreStatus(coreID, true);
}


void PUChainMCore::finish(){
}

}; //namespace

