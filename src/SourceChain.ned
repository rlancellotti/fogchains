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

package fog;

import PositionModule;

//
// Generates messages with a configurable interarrival time.
//
simple SourceChain extends PositionModule {
    parameters:
        @class(SourceChain);
        @display("i=block/source");
        @signal[sentJob](type="long");
        @statistic[sentJob](title="sent event";record=vector?,count;interpolationmode=none);
        volatile double sendInterval @unit(s) = default(exponential(1s));
        // startTime=0 -> start at beginning (with a tink time)
        // startTime<0 -> don't start at all
        double startTime @unit(s) = default(0s);
        // stopTime<0 -> stop at simulation end
        double stopTime @unit(s) = default(-1s);
        volatile object chain=default([{srvName: "firstService",
                               suggestedTime: exponential(1s), // service time. Refer to std capacity PU
                               node: [{id: -1, weight: 1}], // int x means PU x
                               exitProbability: 0.0, // exit probability after each service. Should be float in range [0,1]
                            }]);
        double suggestedDeadline @unit(s) = default(-1s);
        double maxInterval @unit(s) = default(-1s);
        int appId = default(1);
        string jobName = default("job");
        string mappingOracle = default("mappingOracle");
        int packetLength=default(1); 
    gates:
        output out;
}
