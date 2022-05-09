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
simple SourceMulti
{
    parameters:
        @display("i=block/source");
        @signal[sentJob](type="long");
        @statistic[sentJob](title="sent event";record=vector?,count;interpolationmode=none);
        volatile double sendInterval @unit(s) = default(exponential(1s));
        // startTime=0 -> start at beginning (with a tink time)
        // startTime<0 -> don't start at all
        double startTime @unit(s) = default(0s);
        // stopTime<0 -> stop at simulation end
        double stopTime @unit(s) = default(-1s);
        int chainLenght=default(1);
        // FIXME: should fine bettere way to describe properties
        // list of service times for the services. 
        volatile double suggestedTime_1 @unit(s) = default(1s);
        volatile double suggestedTime_2 @unit(s) = default(1s);
        volatile double suggestedTime_3 @unit(s) = default(1s);
        volatile double suggestedTime_4 @unit(s) = default(1s);
        volatile double suggestedTime_5 @unit(s) = default(1s);
        volatile double suggestedTime_6 @unit(s) = default(1s);
        volatile double suggestedTime_7 @unit(s) = default(1s);
        volatile double suggestedTime_8 @unit(s) = default(1s);
        volatile double suggestedTime_9 @unit(s) = default(1s);
        // exit link after each service.
        // int x means go to PU x
        // -1 means exit to sink
        // output_0 is the number of the first PU (from sources)
        int output_0 = default(-1);
        int output_1 = default(-1); 
        int output_2 = default(-1); 
        int output_3 = default(-1); 
        int output_4 = default(-1); 
        int output_5 = default(-1); 
        int output_6 = default(-1); 
        int output_7 = default(-1); 
        int output_8 = default(-1); 
        int output_9 = default(-1); 
        // exit probability after each service.
        // should be float in range [0,1]
        double exitProbability_1 = default(-1); 
        double exitProbability_2 = default(-1); 
        double exitProbability_3 = default(-1); 
        double exitProbability_4 = default(-1); 
        double exitProbability_5 = default(-1); 
        double exitProbability_6 = default(-1); 
        double exitProbability_7 = default(-1); 
        double exitProbability_8 = default(-1); 
        double exitProbability_9 = default(-1); 
        double suggestedDeadline @unit(s) = default(-1s);
        double maxInterval @unit(s) = default(-1s);
        int appId = default(1);
        string jobName =default("job"); 
        int packetLength=default(1); 
    gates:
        output out;
}
