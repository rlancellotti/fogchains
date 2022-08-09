
package fog;

//
// dispatcher: sends jobs to next PU in queue
//
simple DispatcherChain
{
    parameters:
        @display("i=block/dispatch");    
    gates:
        input in[];
        output out[];
        output sinkout;
}
