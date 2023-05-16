package fog;

//
// Generic interface for mobility
//

moduleinterface IMobilityModel {
    parameters:
        @display("i=block/cogwheel");
        @signal[mobilityStateChanged];
}


//
// Generic mobility model
//
simple MobilityModel like IMobilityModel {
    parameters:
        @display("i=block/cogwheel");
        @signal[mobilityStateChanged];
}
