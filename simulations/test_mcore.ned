package fog.simulations;

import fog.SourceChain;
import fog.SinkChain;
import fog.DispatcherChain;
import fog.PUChainMCore;

network TestMCore
{
    parameters:
        int nCores;
        double rho;
    submodules:
        source: SourceChain;
        dispatcher: DispatcherChain;
        pu: PUChainMCore {
            ncores=parent.nCores;
            speedup=1.0/parent.nCores;
            //speedup=1.0;
        };
        sink: SinkChain;
    connections:
        source.out --> dispatcher.in;
        dispatcher.out++ --> pu.in++;
        dispatcher.sinkout --> pu.in++;
        pu.out --> sink.in++;
}
