#ifndef __MAPPING_H
#define __MAPPING_H
#include <vector>
#include <omnetpp.h>

typedef long int nodeid_t;

using namespace omnetpp;

namespace fog {

class ServiceMapping
{
  private:
    cComponent *cComp=nullptr;
    double maxweight=0.0;
    std::vector<double> weights;
    std::vector<long int> ids;

  public:
    ServiceMapping(cValue *v);
    void setComponent(cComponent *c);
    void addElement(long int nodeId, double weight);
    std::vector<long int> *getNodeList();
    nodeid_t getRandomNode();
};
                  
}; // namespace

#endif
