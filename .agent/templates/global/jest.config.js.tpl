/** @type {import('ts-jest').JestConfigWithTsJest} */
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  moduleFileExtensions: ['js', 'json', 'ts'],
  rootDir: '.',
  testRegex: '.*\\.spec\\.ts$',
  transform: {
    '^.+\\.(t|j)s$': ['ts-jest', {
      tsconfig: 'tsconfig.json'
    }]
  },
  moduleNameMapper: {
    '^@enums/(.*)$': '<rootDir>/src/commons/enums/$1',
    '^@commons/(.*)$': '<rootDir>/src/commons/$1',
    '^@modules/(.*)$': '<rootDir>/src/modules/$1',
    '^@{{PRIMARY_MODULE_ALIAS}}/(.*)$': '<rootDir>/src/modules/{{PRIMARY_MODULE_ALIAS}}/$1',
    '^@app/(.*)$': '<rootDir>/src/$1'
  },
  collectCoverageFrom: [
    'src/**/*.(t|j)s',
    '!coverage/**',
    '!dist/**',
    '!node_modules/**',
    '!**/*.module.ts',
    '!src/main.ts',
    '!src/tracing.ts',
    '!src/**/*.config.ts',
    '!**/*.d.ts',
    '!**/node_modules/**'
  ],
  coverageDirectory: './coverage',
  modulePaths: ['<rootDir>/'],
  moduleDirectories: ['node_modules', 'src'],
  transformIgnorePatterns: [
    '/node_modules/'
  ],
  testPathIgnorePatterns: [
    '/node_modules/'
  ]
};
