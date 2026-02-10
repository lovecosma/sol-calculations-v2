module.exports = {
  testEnvironment: 'jsdom',
  testMatch: ['**/spec/javascript/**/*.test.js'],
  moduleNameMapper: {
    '^@hotwired/stimulus$': '<rootDir>/node_modules/@hotwired/stimulus',
  },
  setupFilesAfterEnv: ['<rootDir>/spec/javascript/setup.js'],
  transform: {
    '^.+\\.js$': 'babel-jest',
  },
  collectCoverageFrom: [
    'app/javascript/**/*.js',
    '!app/javascript/application.js',
  ],
  watchman: false,
}
