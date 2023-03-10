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
    timerMessage = nullptr;
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
    cModule *mod=findModuleByPath(par("mappingOracle"));
    if (mod!=nullptr){
        mappingOracle=check_and_cast<MappingOracle *>(mod);
    }
    cValueArray* chain=check_and_cast<cValueArray *>(par("chain").objectValue());
    int chainLenght=getChainLength(chain);
    for (int i=0; i<chainLenght; i++){
        cValueMap *service=check_and_cast<cValueMap *>(chain->get(i).objectValue());
        cValue nodes=service->get("node");
        if (mappingOracle==nullptr){
            ServiceMapping *srv=new ServiceMapping(&nodes);
            srv->setComponent(this);
            mapping.push_back(srv);
        } else {
            //register the services to the mapping oracle
            const char *srvName=service->get("srvName").stringValue();
            srvNames.push_back(srvName);
            mappingOracle->registerService(srvName, &nodes);
        }
    }
}

long int SourceChain2::getChainLength(cValueArray *chain){
    return chain->size();
}

double SourceChain2::getFloatChainParam(cValueArray *chain, int idx, const char *param){
    cValueMap *map=check_and_cast<cValueMap *>(chain->get(idx).objectValue());
    return map->get(param).doubleValue();
}

long int SourceChain2::getNode(int idx){
    // if we have mapping oracle, ask the oracle
    // otherwise, find the right mapping ans ask the service mapping
    if (mappingOracle==nullptr){
        return mapping[idx]->getRandomNode();
    } else {
        // FIXME: must return name of the service
        return mappingOracle->getNodeForService(srvNames[idx]);
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
        job->setOutputs(i, getNode(i));
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
