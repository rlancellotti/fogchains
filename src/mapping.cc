#include "mapping.h"
#include <math.h>

namespace fog {

/*ServiceMapping class*/

ServiceMapping::ServiceMapping(cValue *v){
  if (! v->containsObject()){
        addElement(v->intValue(), 1);
    } else {
        cValueArray *nodes=check_and_cast<cValueArray *>(v->objectValue());
        auto nnodes=nodes->size();
        for (int i=0; i<nnodes; i++){
          cValueMap *node=check_and_cast<cValueMap *>(nodes->get(i).objectValue());
          addElement(node->get("id").intValue(), node->get("weight").doubleValue());
        }
    }
}

void ServiceMapping::setComponent(cComponent * c){cComp=check_and_cast<cComponent *>(c);}
void ServiceMapping::addElement(long int nodeId, double weight){
  weights.push_back(maxweight + weight);
  ids.push_back(nodeId);
  maxweight+=weight;
}

long int ServiceMapping::getRandomNode(){
  auto nnodes = ids.size();
  if (nnodes==0){return -1;}
  if (nnodes==1){return ids[0];}
  // random number
  double rnd=cComp->dblrand()*maxweight;
  // return value
  for (long int i=0; i<nnodes; i++){
      if (weights[i]>=rnd){return ids[i];}
  }
  return ids[nnodes-1];
}

std::vector<long int> *ServiceMapping::getNodeList(){return &ids;}

// End of namespace
}