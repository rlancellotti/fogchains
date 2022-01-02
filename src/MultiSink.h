#ifndef __FOG_MULTISINK_H
#define __FOG_MULTISINK_H

#include <omnetpp.h>

using namespace omnetpp;

namespace fog {

/**
 * Consumes jobs; see NED file for more info.
 */
class MultiSink : public cSimpleModule
{
  private:
	simsignal_t responseTimeSignal;
	simsignal_t totalQueueingTimeSignal;
	simsignal_t queuesVisitedSignal;
	simsignal_t totalServiceTimeSignal;
	simsignal_t totalDelayTimeSignal;
	simsignal_t delaysVisitedSignal;
	//simsignal_t generationSignal;
	
    //bool keepJobs;

  protected:
    virtual void initialize() override;
    virtual void handleMessage(cMessage *msg) override;
    virtual void finish() override;
};

}; //namespace

#endif

