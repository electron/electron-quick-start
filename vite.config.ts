import react from "@vitejs/plugin-react-swc";
import { resolve } from "path";
import { defineConfig } from "vite";

// https://vitejs.dev/config/
export default defineConfig((env) => {
  // const isDev = env.mode === "development";
  return {
    root: resolve("src", "renderer"),
    publicDir: resolve("src", "public"),
    base: "./",
    build: {
      outDir: resolve("build_vite"),
    },

    plugins: [react()],

    server: {
      port: 3000,
    },
  };
});
