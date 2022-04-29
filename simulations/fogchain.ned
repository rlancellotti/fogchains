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

package fog.simulations;

import fog.SourceMulti;
import fog.SinkMulti;
import fog.DelayMulti;
import fog.PUMulti;
import fog.DispatcherMulti;
import fog.AppClassifier;


//
// Sample network, consisting of a source and a sink.
//
network FogChain
{
    parameters:
        int nChains;
        int nNodes;
    submodules:
        source[nChains]: SourceMulti;
        delay[nNodes * nNodes]: DelayMulti;
        initDispatcher[nChains]: DispatcherMulti {
            parameters:
                @display("i=,slategray");
            gates:
                out[parent.nNodes];
        };
        pu[nNodes]: PUMulti;
        dispatcher[nNodes]: DispatcherMulti {
            gates:
                out[parent.nNodes];
        };
        classifier: AppClassifier;
        sink[nChains]: SinkMulti;
        sinkmisc: SinkMulti;
    connections:
        // link source to first level of dispatchers
        for i=0..nChains-1 {
            source[i].out --> initDispatcher[i].in;
        }
        // interconnection of first level of dispaters to nodes
        for d=0..nChains-1, for p=0..nNodes-1 {
            initDispatcher[d].out[p] --> pu[p].in++;
            //dispatcher[d].out[p] --> delay[d*nNodes+p].in++;
            //delay[d*nNodes+p].out --> pu[p].in++;
        } 
        for i=0..nNodes-1 {
            // output of PU with following dispatcher
            pu[i].out --> dispatcher[i].in;
        }
        // interconnection among dispatchers
        for d=0..nNodes-1, for p=0..nNodes-1 {
            //dispatcher[d].out[p] --> pu[p].in++;
            dispatcher[d].out[p] --> delay[d*nNodes+p].in++;
            delay[d*nNodes+p].out --> pu[p].in++;
        } 
        // output of dispatchers towards sink
        for i=0..nNodes-1 {
            dispatcher[i].sinkout --> classifier.in++;
        }
        for i=0..nChains-1 {
            initDispatcher[i].sinkout --> classifier.in++;
        }
        // setup classifier
        for i=0..nChains-1 {
            classifier.out++ --> sink[i].in++;
        }
        classifier.rest --> sinkmisc.in++;
}
