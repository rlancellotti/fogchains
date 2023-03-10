package fog.simulations;

import fog.SourceChain;
import fog.SinkChain;
import fog.DispatcherChain;
import fog.PUChain;

network TestMoG
{
    parameters:
        double lambda1;
        double lambda2;
        double mu1;
        double mu2;
        double cv1;
        double cv2;
        double rho;
    submodules:
        source[2]: SourceChain;
        dispatcher[2]: DispatcherChain;
        pu: PUChain;
        sink: SinkChain;
    connections:
        for i=0..1 {
            source[i].out --> dispatcher[i].in;
            dispatcher[i].out++ --> pu.in++;
            dispatcher[i].sinkout --> pu.in++;
        }
        pu.out --> sink.in++;
}
