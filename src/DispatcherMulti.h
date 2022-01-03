#ifndef __FOG_DISPATCHERMULTI_H
#define __FOG_DISPATCHERMULTI_H

#include <omnetpp.h>

using namespace omnetpp;

namespace fog {

class DispatcherMulti : public cSimpleModule
{
  protected:
    virtual void initialize() override;
    virtual void handleMessage(cMessage *msg) override;
    virtual void finish() override;
};

}; //namespace

#endif

