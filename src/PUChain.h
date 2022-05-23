//
// This file is part of an OMNeT++/OMNEST simulation example.
//
// Copyright (C) 2006-2015 OpenSim Ltd.
//
// This file is distributed WITHOUT ANY WARRANTY. See the file
// `license' for details on this and other legal matters.
//

#ifndef __FOGPUCHAIN_H
#define __FOGPUCHAIN_H

#include <omnetpp.h>
#include "ChainJob_m.h"

using namespace omnetpp;

/*
TODO:
- support for timeout
- support for speedup
- support for service time from message
*/

namespace fog {

class PUChain : public cSimpleModule
{
    private:
		simsignal_t droppedSignal;
		simsignal_t queueLengthSignal;
		simsignal_t queueingTimeSignal;
		simsignal_t busySignal;

        ChainJob *jobServiced;
        cMessage *endServiceMsg;
        cMessage *timeoutMsg;
        cQueue queue;
        int capacity;
        double speedup;

    public:
        PUChain();
        virtual ~PUChain();
        int length();

    protected:
        virtual ChainJob *getFromQueue();
        virtual void initialize() override;
        virtual void handleMessage(cMessage *msg) override;
        virtual void refreshDisplay() const override;
        virtual void finish() override;

        virtual void arrival(ChainJob *job);
        virtual void startService(ChainJob *job);
        virtual void endService(ChainJob *job);
        virtual void abortService(ChainJob *job);
};

}; //namespace

#endif
