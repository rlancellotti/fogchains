#ifndef __FOG_CLASSIFIER_H
#define __FOG_CLASSIFIER_H

#include <omnetpp.h>

using namespace omnetpp;
namespace fog {

/**
 * See the NED declaration for more info.
 */
class  AppClassifier : public cSimpleModule
{
    private:
    protected:
        virtual void handleMessage(cMessage *msg) override;
};

}; //namespace

#endif
