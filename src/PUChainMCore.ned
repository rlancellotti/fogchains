
package fog;

//
// processing unit with many cores and a queue
//
simple PUChainMCore extends PUChain
{
    parameters:
        int ncores = default(1);    //number of cores
}
