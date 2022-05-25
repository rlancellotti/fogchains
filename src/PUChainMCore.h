//
// This file is part of an OMNeT++/OMNEST simulation example.
//
// Copyright (C) 2006-2015 OpenSim Ltd.
//
// This file is distributed WITHOUT ANY WARRANTY. See the file
// `license' for details on this and other legal matters.
//

#ifndef __FOGPUCHAINMULTICORE_H
#define __FOGPUCHAINMULTICORE_H

#include <vector>
#include <omnetpp.h>
#include "ChainJob_m.h"
#include "PUChain.h"

using namespace omnetpp;

/*
TODO:
- support for timeout
- support for speedup
- support for service time from message
*/

namespace fog {

class PUChainMCore : public PUChain
{
    private:
		simsignal_t droppedSignal;
		simsignal_t queueLengthSignal;
		simsignal_t queueingTimeSignal;
		simsignal_t busySignal; // this signal provides the numebr of busy cores

        std::vector<bool> busyCore; // status of the cores

        std::vector<ChainJob *> jobServiced;
        std::vector<cMessage *> endServiceMsg;
        std::vector<cMessage *> timeoutMsg;
        int ncores;
        int lastUsedCore;

        int getBusyCores() const;
        int getEndServiceMsgId(cMessage *msg);
        int getTimeoutMsgId(cMessage *msg);

        int getCoreFromJob(ChainJob *job);
        void printCores();

    public:
        PUChainMCore();
        virtual ~PUChainMCore();

    protected:
        virtual void initialize() override;
        virtual void handleMessage(cMessage *msg) override;
        virtual void refreshDisplay() const override;
        virtual void finish() override;

        virtual void setFreeCore(int coreID);
        virtual void setBusyCore(int coreID);
        virtual void setCoreStatus(int coreID, bool busy);
        virtual int getBestCore();


        //virtual void arrival(ChainJob *job) override;
        virtual void startService(ChainJob *job) override;
        virtual void endService(int jobCoreID);
        virtual void endService(ChainJob *job) override;
        virtual void abortService(int jobCoreID);
        virtual void abortService(ChainJob *job) override;
};

}; //namespace

#endif
