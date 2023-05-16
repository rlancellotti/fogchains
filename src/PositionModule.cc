#include "PositionModule.h"
#include "MobilityModel.h"

namespace fog {

Define_Module(PositionModule);

void PositionModule::initialize(){
    cModule *mod=findModuleByPath(par("mobilityModel"));
    if (mod!=nullptr){
        setMobilityModel(check_and_cast<MobilityModel *>(mod));
        // FIXME: must register self to mobility model
        mobilityModel->registerAgent(this, this->getName());
    }
}
void PositionModule::updatePosition(double x, double y){position=cFigure::Point(x,y);}
cFigure::Point *PositionModule::getPosition(){return &position;}
void PositionModule::setMobilityModel(MobilityModel *mm){mobilityModel=mm;}
}