
package fog;

//
// dispatcher: sends jobs to next PU in queue
//
simple DispatcherMulti
{
    parameters:
    gates:
        input in;
        output out[];
        output sinkout;
}
