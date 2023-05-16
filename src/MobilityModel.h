#ifndef __FOG_MOBILITY_H
#define __FOG_MOBILITY_H

#include <omnetpp.h>
#include <map>
#include "PositionModule.h"

using namespace omnetpp;

namespace fog {

/**
 * Consumes jobs; see NED file for more info.
 */
class MobilityModel : public cSimpleModule
{
  private:
    std::map<const char *, cSimpleModule *> agents;
    cMessage *updatePositionMessage;

  protected:
    virtual void initialize() override;
    virtual void handleMessage(cMessage *msg) override;
    virtual void finish() override;
    virtual void updatePositions();
  public:
    virtual void registerAgent(PositionModule *, const char *id);
};

}; //namespace

#endif

