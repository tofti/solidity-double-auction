require("@nomiclabs/hardhat-solhint")
require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */

module.exports = {
  solidity: {
    // other solidity settings...

    // add the following settings for solhint
    compilers: [
      {
        version: '0.8.18', // the version of the Solidity compiler you are using
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],

  },

    // configure the solhint plugin
    solhint: {
      "max-line-length": ["error", 120],
      "no-unused-vars": "error",
      "no-empty-blocks": "error",
      "no-multi-spaces": "error",
      "no-trailing-spaces": "error",
      "space-before-function-paren": ["error", "never"],
      "keyword-spacing": "error",
      "brace-style": ["error", "1tbs"],
      "eqeqeq": ["error", "always", { "null": "ignore" }],
      "camelcase": ["error", { "properties": "never" }],
      "func-names": "off",
      "prefer-arrow-callback": "error",
      "no-inner-declarations": "off",
      "no-var": "error",
      "object-shorthand": "error",
      "quotes": ["error", "single"],
      "semi": ["error", "always"],
      "strict": "off",
      "yul-no-unused-vars": "error",
      "no-unreachable": "error",
      "no-mixed-spaces-and-tabs": ["error", "smart-tabs"],
      "no-trailing-spaces": "error",
      "no-multiple-empty-lines": ["error", { "max": 1, "maxEOF": 0 }],
      "no-extra-semi": "error",
      "eol-last": ["error", "always"],
    },

};