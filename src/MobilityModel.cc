#include "MobilityModel.h"
namespace fog {

Define_Module(MobilityModel);

void MobilityModel::initialize(){
    updatePositionMessage = new cMessage("updatePosition");
}
void MobilityModel::handleMessage(cMessage *msg){}
void MobilityModel::registerAgent(PositionModule *, const char *id){}
void MobilityModel::updatePositions(){}
void MobilityModel::finish(){}
}
