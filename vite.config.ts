import { defineConfig } from 'vite'
import path from 'path'
import { existsSync, readFileSync } from "node:fs"
import RubyPlugin from 'vite-plugin-ruby'
import FullReload from 'vite-plugin-full-reload'
import StimulusHMR from 'vite-plugin-stimulus-hmr' 

const certPath = "./config/ssl/dev.bifrost.com.pem"
const keyPath = "./config/ssl/dev.bifrost.com-key.pem"
const https = existsSync(certPath)
  ? { key: readFileSync(keyPath), cert: readFileSync(certPath) }
  : {};

export default defineConfig({
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './app/javascript/entrypoints'),
    },
  },
  plugins: [
    RubyPlugin(),
    FullReload(['config/routes.rb', 'app/views/**/*'], { delay: 200 }),
    StimulusHMR(),
  ],
  server: {
    https
  }
})
