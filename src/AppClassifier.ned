package fog;

//
// Sends the messages to different outputs depending on messages app ID
// If no output found for a message, it is dropped
// Messages with app = i will be sent to out[i]
//
simple AppClassifier
{
    parameters:
        @display("i=block/classifier");
    gates:
        input in[];
        output out[];
        output rest;
}
