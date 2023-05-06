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

import fog.SourceChain2;
import fog.SinkChain;
import fog.DelayChain;
import fog.PUChain;
import fog.DispatcherChain;
import fog.AppClassifier;
import fog.MappingOracle;

//
// Sample network, consisting of a source and a sink.
//
network FogChain
{
    parameters:
        int nChains;
        int nNodes;
        int nSrcPerChain = default(1);
        bool networkDelay = default(false);
        bool enableMappingOracle = default(false);
        //string pustring=choose(int(networkDelay), "p=,,c p=,,ri");
    submodules:
        source[nChains*nSrcPerChain]: SourceChain2;
        mappingOracle: MappingOracle if enableMappingOracle;
        delay[nNodes * nNodes]: DelayChain if networkDelay {
            parameters:
                @display("p=,,c;is=vs");
        };
        initDispatcher[nChains]: DispatcherChain {
            parameters:
                @display("p=,,c;i=,slategray");
            gates:
                out[parent.nNodes];
        };
        pu[nNodes]: PUChain {
            parameters:
                @display("p=,,c");
                //pudisplay = parent.networkDelay?",,c":",,ri";
        };
        dispatcher[nNodes]: DispatcherChain {
            parameters:
                @display("p=,,c");
            gates:
                out[parent.nNodes];
        };
        classifier: AppClassifier;
        sink[nChains]: SinkChain{
            parameters:
                @display("p=,,c");
        };
        sinkmisc: SinkChain;
    connections:
        // link source to first level of dispatchers
        for i=0..nChains-1, for r=0..nSrcPerChain-1 {
            source[(i*nSrcPerChain)+r].out --> initDispatcher[i].in++;
        }
        // interconnection of first level of dispaters to nodes
        for d=0..nChains-1, for p=0..nNodes-1 {
            initDispatcher[d].out[p] --> pu[p].in++;
        } 
        for i=0..nNodes-1 {
            // output of PU with following dispatcher
            pu[i].out --> dispatcher[i].in++;
        }
        // interconnection among dispatchers
        for d=0..nNodes-1, for p=0..nNodes-1 {
            dispatcher[d].out[p] --> pu[p].in++ if ! networkDelay;
            dispatcher[d].out[p] --> delay[d*nNodes+p].in++ if networkDelay;
            delay[d*nNodes+p].out --> pu[p].in++ if networkDelay;
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
