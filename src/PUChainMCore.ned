
package fog;

//
// processing unit with many cores and a queue
//
simple PUChainMCore extends PUChain like IPUChain
{
    parameters:
        @class(PUChainMCore);
        //int ncores = default(1);    // number of cores. already available from superclass
}
