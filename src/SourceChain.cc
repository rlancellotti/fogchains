//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
// 

#include "SourceChain.h"
#include "ChainJob_m.h"

namespace fog {

Define_Module(SourceChain);

SourceChain::SourceChain()
{
    timerMessage = NULL;
}

SourceChain::~SourceChain()
{
    cancelAndDelete(timerMessage);
}

void SourceChain::initialize()
{
    startTime = par("startTime");
    stopTime = par("stopTime");
    timerMessage = new cMessage("timer");
    maxInterval = par("maxInterval");
    sentJobSignal = registerSignal("sentJob");
    if (startTime>=0) {
        scheduleJob(startTime);
    }
}

/**
 * When the timer is triggered, the job is created, initialized and send 'out'
 * Next timer is scheduled
 */

void SourceChain::handleMessage(cMessage *msg)
{
    ASSERT(msg==timerMessage);
    // stop condition
    if (stopTime >= 0 && stopTime < simTime()) {
        EV<<this->getFullName()<<" discarding event because sourc already stopped"<<endl;
        return;
    }
    // create new message
    ChainJob *job = new ChainJob(getJobName());
    job->setStartTime(simTime());
    job->setQueuingTime(0.0);
    job->setServiceTime(0.0);
    job->setDelayTime(0.0);
    job->setQueueCount(0);
    job->setDelayCount(0);
    job->setAppId(par("appId").intValue());
    int chainLenght=par("chainLenght").intValue();
    job->setSuggestedTimeArraySize(chainLenght+1); 
    job->setOutputsArraySize(chainLenght+1); 
    job->setExitProbabilityArraySize(chainLenght+1); 
    job->setLastService(-1);
    for (int i=0; i<chainLenght+1; i++){
        if (i>0) {
            std::string partimename = "suggestedTime_" + std::to_string(i);
            job->setSuggestedTime(i, par(partimename.c_str()));
            std::string parexitname = "exitProbability_" + std::to_string(i);
            job->setExitProbability(i, par(parexitname.c_str()));
        } else {
            job->setSuggestedTime(i, 0.0);
            job->setExitProbability(i, 0.0);
        }
        std::string paroutname = "output_" + std::to_string(i);
        job->setOutputs(i, par(paroutname.c_str()).intValue());
    }
    if (par("suggestedDeadline").doubleValue()>0.0){
        job->setSlaDeadline(simTime()+par("suggestedDeadline"));
    } else {
        job->setSlaDeadline(-1.0);
    }
    job->setByteLength(par("packetLength"));
    //EV << "ID is: "<< job->getId() <<endl;
    //job->setId(nextJobId++);
    send(job, "out");
    emit(sentJobSignal, 1);
    // schedule next message
    scheduleJob(simTime());
}

void SourceChain::scheduleJob(simtime_t offset){
    simtime_t t, trand;
    trand=par("sendInterval");
    t=(maxInterval>0 && trand>maxInterval)?t=offset + maxInterval:t=offset + trand;
    //EV<<"schedule job @t="<<t<<endl;
    scheduleAt(t, timerMessage);
}

const char *SourceChain::getJobName(){
    return par("jobName");
}


}; // namespace
