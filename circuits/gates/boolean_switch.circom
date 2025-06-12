pragma circom 2.1.4;

/*
 * Boolean Switch circuit for conditional flow control
 * Implements AND, OR, and NOT gates for flow logic
 */
template BooleanSwitch() {
    signal input in[2];  // Two boolean inputs
    signal input selector; // 0: AND, 1: OR, 2: NOT(in[0])
    signal output out;

    // Ensure inputs are binary
    in[0] * (in[0] - 1) === 0;
    in[1] * (in[1] - 1) === 0;
    
    // Compute AND
    signal andGate;
    andGate <== in[0] * in[1];

    // Compute OR
    signal orGate;
    orGate <== in[0] + in[1] - (in[0] * in[1]);

    // Compute NOT
    signal notGate;
    notGate <== 1 - in[0];

    // Select output based on selector
    signal selectorCheck1;
    signal selectorCheck2;
    selectorCheck1 <== selector * (selector - 1);
    selectorCheck2 <== selector * (selector - 2);
    selectorCheck1 * selectorCheck2 === 0;

    out <== (andGate * (1 - selector) * (2 - selector)) / 2 + 
           (orGate * selector * (2 - selector)) / 2 +
           (notGate * selector * (selector - 1)) / 2;
} 