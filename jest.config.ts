import { JestConfigWithTsJest } from "ts-jest";

const config: JestConfigWithTsJest = {
  preset: "ts-jest",
  testEnvironment: "jsdom", // Or 'node' for server-side testing
  testMatch: ["**/src/**/*.test.ts"],
  moduleNameMapper: {},
  transform: {},
};

export default config;
