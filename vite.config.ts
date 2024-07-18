import { defineConfig } from 'vite'
import path from 'path'
import { existsSync, readFileSync } from "node:fs"
import RubyPlugin from 'vite-plugin-ruby'
import FullReload from 'vite-plugin-full-reload'
import StimulusHMR from 'vite-plugin-stimulus-hmr' 

// const certPath = "./config/ssl/dev.bifrost.com.pem"
// const keyPath = "./config/ssl/dev.bifrost.com-key.pem"
// const https = existsSync(certPath)
//   ? { key: readFileSync(keyPath), cert: readFileSync(certPath) }
//   : {};

export default defineConfig({
  clearScreen: false,
  base: './',
  publicDir: 'public',
  resolve: {
    alias: {
      '@js': path.resolve(__dirname, './app/frontend/javascript'),
      '@css': path.resolve(__dirname, './app/frontend/stylesheets'),
      '@img': path.resolve(__dirname, './app/frontend/images'),
      '@fonts': path.resolve(__dirname, './app/frontend/fonts')
    },
  },
  plugins: [
    RubyPlugin(),
    FullReload(['config/routes.rb', 'app/views/**/*'], { delay: 200 }),
    StimulusHMR(),
  ],
  build: {
    outDir: './public/assets/',
    emptyOutDir: true,
    cssCodeSplit: true,
    manifest: true
  },
  server: {
    origin: 'http://localhost:5000'
  }
})
