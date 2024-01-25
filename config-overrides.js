const path = require("path");

module.exports = {
  paths: (reactPaths) => {
    reactPaths.appPublic = path.resolve(__dirname, "public");
    reactPaths.appHtml = path.resolve(__dirname, "public/index.html");
    reactPaths.appSrc = path.resolve(__dirname, "src/renderer");
    reactPaths.appIndexJs = path.resolve(__dirname, "src/renderer/index.tsx");
    return reactPaths;
  },
  webpack: (reactConfig, env) => {
    const isDev = env === "development";
    if (!isDev) reactConfig.output.publicPath = "./";
    return reactConfig;
  },
};
