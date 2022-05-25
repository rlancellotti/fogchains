
package fog;

//
// processing unit with many cores and a queue
//
simple PUChainMCore extends PUChain
{
    parameters:
        @class(PUChainMCore);
        int ncores = default(1);    //number of cores
}
