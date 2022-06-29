
package fog;

//
// processing unit with a queue
//
simple PUChain
{
    parameters:
        @display("i=block/activeq;q=queue");
        @signal[dropped](type="long");
        @signal[queueLength](type="long");
        @signal[queueingTime](type="simtime_t");
        @signal[serviceTime](type="simtime_t");
        @signal[interarrivalTime](type="simtime_t");
        @signal[busy](type="int");
        @statistic[dropped](title="drop event";record=vector?,count;interpolationmode=none);
        @statistic[queueLength](title="queue length";record=vector,timeavg,max;interpolationmode=sample-hold);
        @statistic[queueingTime](title="queueing time";record=vector?,stats;unit=s;interpolationmode=none);
        @statistic[serviceTime](title="service time";record=vector?,stats,histogram;unit=s;interpolationmode=none);
        @statistic[interarrivalTime](title="inter-arrival time";record=vector?,stats,histogram;unit=s;interpolationmode=none);
        @statistic[busy](title="server busy state";record=vector?,timeavg;interpolationmode=sample-hold);
        double speedup = default(1.0);  //speedup: suggested time is divided by speedup value
        int capacity = default(-1);    // negative capacity means unlimited queue
        //string pudisplay = default("c");
    gates:
        input in[];
        output out;
}
