import * as esbuild from "esbuild"
import vuePlugin from "esbuild-plugin-vue3"

await esbuild.build({
  entryPoints: [
    "app/javascript/application.js",
    { in: "app/javascript/builder.js", out: "builder" }
  ],
  bundle: true,
  sourcemap: true,
  format: "esm",
  outdir: "app/assets/builds",
  publicPath: "/assets",
  plugins: [vuePlugin()],
})