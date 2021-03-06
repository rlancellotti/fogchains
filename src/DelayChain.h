//
// This file is part of an OMNeT++/OMNEST simulation example.
//
// Copyright (C) 2006-2015 OpenSim Ltd.
//
// This file is distributed WITHOUT ANY WARRANTY. See the file
// `license' for details on this and other legal matters.
//

#ifndef __DELAYCHAIN_H
#define __DELAYCHAIN_H

#include <omnetpp.h>
#include "ChainJob_m.h"

using namespace omnetpp;

namespace fog {

/**
 * Delays the incoming messages
 */
class DelayChain : public cSimpleModule
{
    private:
		simsignal_t delayedJobsSignal;
        int currentlyStored;
    protected:
        virtual void initialize() override;
        virtual void handleMessage(cMessage *msg) override;
        virtual void refreshDisplay() const override;
};

}; //namespace

#endif

