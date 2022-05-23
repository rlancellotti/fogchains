package fog;

simple DelayChain
{
    parameters:
        @signal[delayedJobs](type="long");
        @statistic[delayedJobs](title="number of delayed jobs";record=vector?,timeavg,max;interpolationmode=sample-hold);
        @display("i=block/delay");
        volatile double delay @unit(s); // the requested delay time (can be a distribution)
    gates:
        input in[];                     // the incoming message gates
        output out;                     // outgoing message gate
}
