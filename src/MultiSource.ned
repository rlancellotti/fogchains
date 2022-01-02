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

//
// Generates messages with a configurable interarrival time.
//
simple MultiSource
{
    parameters:
        @display("i=block/source");
        @signal[sentJob](type="long");
        @statistic[sentJob](title="sent event";record=vector?,count;interpolationmode=none);
        volatile double sendInterval @unit(s) = default(exponential(1s));
        int chainLenght=default(1);
        // list of service times for the services. Only #0 is shown
        volatile double suggestedTime_0 @unit(s) = default(-1s);
        // exit link after each service. Only #0 is shown
        // int x means go to exit X
        // -1 means remain on same node
        int output_0 = default -1; 
        double suggestedDeadline @unit(s) = default(-1s);
        double maxInterval @unit(s) = default(-1s);
        int appId = default(0);
        string jobName =default("job"); 
        int packetLength=default(1); 
    gates:
        output out;
}
