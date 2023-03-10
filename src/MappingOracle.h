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

#ifndef __MAPPINGORACLE_H
#define __MAPPINGORACLE_H

#include <omnetpp.h>
#include <map>
#include "mapping.h"
using namespace omnetpp;
namespace fog {

class MappingOracle : public cSimpleModule
{
  private:
    std::map<nodeid_t, cFigure::Point> nodePositions;
    std::map<const char*, ServiceMapping *> services;
  public:
    MappingOracle();
    cFigure::Point getNodePosition(nodeid_t nodeId);
    virtual ~MappingOracle();
    void registerNodePos(nodeid_t nodeId, double x, double y);
    void registerNodePos(nodeid_t nodeId, const cFigure::Point &p);
    void registerService(const char *srvName, cValue *v, bool forceUpdate=false);
    void registerService(const char *srvName, ServiceMapping *mapping, bool forceUpdate=false);
    nodeid_t getNearestNode(double x, double y, std::map<nodeid_t, cFigure::Point> *p=nullptr);
    nodeid_t getNearestNode(double x, double y, const char *srvName);
    nodeid_t getNodeForService(const char *srvName);
};

}; // namespace

#endif
