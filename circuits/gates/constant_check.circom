pragma circom 2.1.4;

/*
 * Constant Check circuit for validating values against predefined constants
 * Supports equality, greater than, and less than comparisons
 */
template ConstantCheck() {
    signal input value;
    signal input constant;
    signal input compareType; // 0: equals, 1: greater than, 2: less than
    signal output isValid;

    // Compute equality check
    signal equalCheck;
    equalCheck <== (value - constant) * (value - constant);
    signal isEqual;
    isEqual <== equalCheck === 0 ? 1 : 0;

    // Compute greater than
    signal greaterCheck;
    greaterCheck <== value > constant ? 1 : 0;

    // Compute less than
    signal lessCheck;
    lessCheck <== value < constant ? 1 : 0;

    // Select output based on compareType
    signal typeCheck1;
    signal typeCheck2;
    typeCheck1 <== compareType * (compareType - 1);
    typeCheck2 <== compareType * (compareType - 2);
    typeCheck1 * typeCheck2 === 0;

    isValid <== (isEqual * (1 - compareType) * (2 - compareType)) / 2 +
                (greaterCheck * compareType * (2 - compareType)) / 2 +
                (lessCheck * compareType * (compareType - 1)) / 2;
} 