module.exports = {
  parser: '@typescript-eslint/parser',
  parserOptions: {
    sourceType: 'module',
    project: './tsconfig.json',
    ecmaFeatures: {
      jsx: true
    }
  },
  plugins: ['react-hooks'],
  extends: [
    'plugin:react/recommended',
    'plugin:@typescript-eslint/recommended',
    'prettier/@typescript-eslint',
    'plugin:prettier/recommended',
    'plugin:react-hooks/recommended'
  ],
  settings: {
    react: {
      version: 'detect'
    }
  },
  reportUnusedDisableDirectives: true,
  rules: {
    '@typescript-eslint/array-type': ['warn', { default: 'array', readonly: 'array' }],
    '@typescript-eslint/camelcase': 'warn',
    '@typescript-eslint/consistent-type-definitions': ['warn', 'interface'],
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/no-empty-function': 'off',
    '@typescript-eslint/no-explicit-any': 'off',
    '@typescript-eslint/no-namespace': 'off',
    '@typescript-eslint/no-unnecessary-boolean-literal-compare': 'warn',
    '@typescript-eslint/no-unused-vars': [
      'warn',
      { varsIgnorePattern: '^_', argsIgnorePattern: '^_' }
    ],
    '@typescript-eslint/no-var-requires': 'off',
    // '@typescript-eslint/no-use-before-define': [
    //   'warn',
    //   {
    //     functions: false,
    //     classes: true,
    //     variables: true,
    //     enums: true,
    //     typedefs: false
    //   }
    // ],
    '@typescript-eslint/no-use-before-define': 'off',
    '@typescript-eslint/strict-boolean-expressions': 'warn',
    'arrow-body-style': ['warn', 'as-needed'],
    'array-callback-return': 'off',
    'comma-dangle': [
      'warn',
      {
        arrays: 'always-multiline',
        objects: 'always-multiline',
        imports: 'always-multiline',
        exports: 'always-multiline',
        functions: 'always-multiline'
      }
    ],
    'max-len': [
      'warn',
      { code: 100, tabWidth: 2, ignoreStrings: true, ignoreTemplateLiterals: true }
    ],
    'no-console': 'off',
    'no-empty-function': 'off',
    'no-inner-declarations': 'off',
    'no-multiple-empty-lines': ['warn', { max: 1 }],
    'no-multi-spaces': 'warn',
    'no-redeclare': 'off',
    'no-shadow': 'off',
    'no-undef': 'off',
    'prettier/prettier': 'off',
    'react/display-name': 'off',
    'react/jsx-no-bind': [
      'warn',
      {
        ignoreDOMComponents: false,
        ignoreRefs: false,
        allowArrowFunctions: false,
        allowFunctions: false,
        allowBind: false
      }
    ],
    'react/no-unescaped-entities': 'off',
    'react/prop-types': 'off',
    'react/self-closing-comp': ['warn', { component: true, html: true }],
    quotes: ['warn', 'single', { avoidEscape: true, allowTemplateLiterals: true }],
    'sort-imports': 'off',
    'space-in-parens': ['warn', 'never'],
    strict: 'warn'
  }
}
