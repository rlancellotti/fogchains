//
// This file is part of an OMNeT++/OMNEST simulation example.
//
// Copyright (C) 2006-2015 OpenSim Ltd.
//
// This file is distributed WITHOUT ANY WARRANTY. See the file
// `license' for details on this and other legal matters.
//

#ifndef __FOGNODEMULTI_H
#define __FOGNODEMULTI_H

#include <omnetpp.h>
#include "MultiJob_m.h"

using namespace omnetpp;

/*
TODO:
- support for timeout
- support for speedup
- support for service time from message
*/

namespace fog {

class PUMulti : public cSimpleModule
{
    private:
		simsignal_t droppedSignal;
		simsignal_t queueLengthSignal;
		simsignal_t queueingTimeSignal;
		simsignal_t busySignal;

        MultiJob *jobServiced;
        cMessage *endServiceMsg;
        cMessage *timeoutMsg;
        cQueue queue;
        int capacity;
        bool fifo;
        MultiJob *getFromQueue();

    public:
        PUMulti();
        virtual ~PUMulti();
        int length();

    protected:
        virtual void initialize() override;
        virtual void handleMessage(cMessage *msg) override;
        virtual void refreshDisplay() const override;
        virtual void finish() override;

        // hook functions to (re)define behaviour
        virtual void arrival(MultiJob *job);
        virtual simtime_t startService(MultiJob *job);
        virtual void endService(MultiJob *job);
};

}; //namespace

#endif
