#include "MappingOracle.h"

namespace fog {

Define_Module(MappingOracle);

MappingOracle::MappingOracle() = default;
MappingOracle::~MappingOracle(){nodePositions.clear();}
void MappingOracle::registerNodePos(nodeid_t nodeId, const cFigure::Point &p){nodePositions[nodeId]=p;}
void MappingOracle::registerNodePos(nodeid_t nodeId, double x, double y){registerNodePos(nodeId, cFigure::Point(x,y));}
void MappingOracle::registerService(const char* srvName, cValue *v, bool forceUpdate){
    if ((services.find(srvName) == services.end()) || forceUpdate) {
        registerService(srvName, new ServiceMapping(v), forceUpdate);
    }
}
void MappingOracle::registerService(const char* srvName, ServiceMapping *mapping, bool forceUpdate){
    if ((services.find(srvName) == services.end()) || forceUpdate){
        if (services.find(srvName) != services.end()){
            services.erase(srvName); // clean if must replace
        }
        mapping->setComponent(this);
        services[srvName]=mapping;
    }
}

cFigure::Point MappingOracle::getNodePosition(nodeid_t nodeId){
    return nodePositions[nodeId];
}

nodeid_t MappingOracle::getNearestNode(double x, double y, const char *srvName){
    std::map<nodeid_t, cFigure::Point> nodes;
    ServiceMapping *sm=services[srvName];
    // for each node find position and add to nodes
    for(nodeid_t n : *(sm->getNodeList())){
        nodes[n]=getNodePosition(n);
    }
    return getNearestNode(x, y, &nodes);
}

nodeid_t MappingOracle::getNearestNode(double x, double y, std::map<nodeid_t, cFigure::Point> *p){
    nodeid_t nearest=-1;
    double dist=-1;
    if (p==nullptr) {p=&nodePositions;}
    for (auto const& iter: *p){
        double d=iter.second.distanceTo(cFigure::Point(x, y));
        if ((dist <0) || (d < dist)){
            dist=d;
            nearest=iter.first;
        }
    }
    return nearest;
}
nodeid_t MappingOracle::getNodeForService(const char *srvName){
    return services[srvName]->getRandomNode();
}

}