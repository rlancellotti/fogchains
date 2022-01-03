
package fog;

//
// dispatcher: sends jobs to next PU in queue
//
simple DispatcherMulti
{
    parameters:
        @display("i=block/dispatch");    
    gates:
        input in;
        output out[];
        output sinkout;
}
