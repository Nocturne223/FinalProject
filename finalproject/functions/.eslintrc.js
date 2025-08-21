module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    "ecmaVersion": 2018,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", {"allowTemplateLiterals": true}],
    // Allow tabs and configure indentation to tabs
    "no-tabs": "off",
    "indent": ["error", "tab", {"SwitchCase": 1}],
    // Do not enforce spacing inside object curly braces
    "object-curly-spacing": "off",
    // Relax stylistic rules to unblock deploy
    "comma-dangle": "off",
    "max-len": "off",
    "no-unused-vars": "off",
    "linebreak-style": "off",
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
    {
      files: [".eslintrc.js"],
      rules: {
        indent: "off",
        "object-curly-spacing": "off",
        "quote-props": "off",
      },
    },
  ],
  globals: {},
};
