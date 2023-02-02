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

#ifndef __SOURCECHAIN2_H
#define __SOURCECHAIN2_H

#include <omnetpp.h>
using namespace omnetpp;
#include "ChainJob_m.h"

namespace fog {

/**
 * Generates messages; see NED file for more info.
 */
class SourceChain2 : public cSimpleModule
{
  private:
    cMessage *timerMessage;
    simtime_t maxInterval;
    simtime_t startTime;
    simtime_t stopTime;
    simsignal_t sentJobSignal;

  public:
    SourceChain2();
    virtual ~SourceChain2();
    const char *getJobName();

  protected:
    virtual void initialize();
    virtual void handleMessage(cMessage *msg);
    virtual ChainJob *createJob();
    virtual int getChainLength(cValueArray *chain);
    virtual int getNode(cValueArray *chain, int idx);
    virtual double getFloatChainParam(cValueArray *chain, int idx, const char *param);
    virtual void scheduleJob(simtime_t offset);
};

}; // namespace

#endif