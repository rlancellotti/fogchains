#ifndef __FOG_DISPATCHERCHAIN_H
#define __FOG_DISPATCHERCHAIN_H

#include <omnetpp.h>

using namespace omnetpp;

namespace fog {

class DispatcherChain : public cSimpleModule
{
  protected:
    virtual void initialize() override;
    virtual void handleMessage(cMessage *msg) override;
    virtual void finish() override;
};

}; //namespace

#endif

