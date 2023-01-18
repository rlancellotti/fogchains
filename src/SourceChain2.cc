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

#include "SourceChain2.h"
#include "ChainJob_m.h"

namespace fog {

Define_Module(SourceChain2);

SourceChain2::SourceChain2()
{
    timerMessage = NULL;
}

SourceChain2::~SourceChain2()
{
    cancelAndDelete(timerMessage);
}

void SourceChain2::initialize()
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

int SourceChain2::getChainLength(cValueArray *chain){
    return chain->size();
}

double SourceChain2::getFloatChainParam(cValueArray *chain, int idx, const char *param){
    cValueMap *map=check_and_cast<cValueMap *>(chain->get(idx).objectValue());
    return map->get(param).doubleValue();
}

int SourceChain2::getNode(cValueArray *chain, int idx){
    cValueMap *map=check_and_cast<cValueMap *>(chain->get(idx).objectValue());
    if (! map->get("node").containsObject()){
        return map->get("node").intValue();
    } else {
        cValueArray *nodes=check_and_cast<cValueArray *>(map->get("node").objectValue());
        int nnodes=nodes->size();
        // initialize data structures
        double maxweight=0.0;
        double weights[nnodes];
        int ids[nnodes];
        for (int i=0; i<nnodes; i++){
            cValueMap *node=check_and_cast<cValueMap *>(nodes->get(i).objectValue());
            ids[i]=node->get("id").intValue();
            weights[i]=maxweight+node->get("weight").doubleValue();
            maxweight=weights[i];
        }
        // random number
        double rnd=dblrand()*maxweight;
        // return value
        for (int i=0; i<nnodes; i++){
            if (weights[i]>=rnd)
                return ids[i];
        }
        return ids[nnodes-1];
    }
}

ChainJob *SourceChain2::createJob(){
    // create new message
    ChainJob *job = new ChainJob(getJobName());
    job->setStartTime(simTime());
    job->setQueuingTime(0.0);
    job->setServiceTime(0.0);
    job->setDelayTime(0.0);
    job->setQueueCount(0);
    job->setDelayCount(0);
    job->setAppId(par("appId").intValue());
    cValueArray* chain=check_and_cast<cValueArray *>(par("chain").objectValue());
    int chainLenght=getChainLength(chain);
    job->setSuggestedTimeArraySize(chainLenght+1); 
    job->setOutputsArraySize(chainLenght+1); 
    job->setExitProbabilityArraySize(chainLenght+1); 
    job->setLastService(-1);
    // FIXME: for each element of the array
    // content is a cValueMap
    // find:
    // - suggestedTime
    // - node
    // - exitProbaiblity
    // NOTE: numbering start from 1 and goes to chainLenght
    // NOTE2: output -> node [i+1]. Output starts from 0 and goes to chainLenght-1
    job->setSuggestedTime(0, 0.0);
    job->setExitProbability(0, 0.0);
    job->setOutputs(chainLenght, -1);
    for (int i=0; i<chainLenght; i++){
        job->setSuggestedTime(i+1, getFloatChainParam(chain, i, "suggestedTime"));
        job->setExitProbability(i+1, getFloatChainParam(chain, i, "exitProbability"));
        //EV << "exit probability["<< i+1 <<"]: " << job->getExitProbability(i+1)<<endl;
        job->setOutputs(i, getNode(chain, i));
    }
    if (par("suggestedDeadline").doubleValue()>0.0){
        job->setSlaDeadline(simTime()+par("suggestedDeadline"));
    } else {
        job->setSlaDeadline(-1.0);
    }
    job->setByteLength(par("packetLength"));
    return job;
}

/**
 * When the timer is triggered, the job is created, initialized and send 'out'
 * Next timer is scheduled
 */

void SourceChain2::handleMessage(cMessage *msg)
{
    ASSERT(msg==timerMessage);
    // stop condition
    if (stopTime >= 0 && stopTime < simTime()) {
        EV<<this->getFullName()<<" discarding event because sourc already stopped"<<endl;
        return;
    }
    ChainJob *job=createJob();
    send(job, "out");
    emit(sentJobSignal, 1);
    // schedule next message
    scheduleJob(simTime());
}

void SourceChain2::scheduleJob(simtime_t offset){
    simtime_t t, trand;
    trand=par("sendInterval");
    t=(maxInterval>0 && trand>maxInterval)?t=offset + maxInterval:t=offset + trand;
    //EV<<"schedule job @t="<<t<<endl;
    scheduleAt(t, timerMessage);
}

const char *SourceChain2::getJobName(){
    return par("jobName");
}


}; // namespace
