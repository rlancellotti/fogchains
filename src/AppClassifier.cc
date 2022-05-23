#include "AppClassifier.h"
#include "ChainJob_m.h"

namespace fog {

Define_Module(AppClassifier);

void AppClassifier::handleMessage(cMessage *msg)
{
    ChainJob *job = check_and_cast<ChainJob *>(msg);
    int outGateIndex = job->getAppId()-1;
    EV << "sendng job to gate " << outGateIndex << "\n";
    if (outGateIndex < 0 || outGateIndex >= gateSize("out"))
        if(gate("rest")->isConnected()){
            send(job, "rest");
        } else {
            delete job;
        }
    else
        send(job, "out", outGateIndex);
}

}; //namespace

