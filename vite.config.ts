import { defineConfig } from 'vite'
import path from 'path'
import RubyPlugin from 'vite-plugin-ruby'
import FullReload from 'vite-plugin-full-reload'
import StimulusHMR from 'vite-plugin-stimulus-hmr' 

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
})
