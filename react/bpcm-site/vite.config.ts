import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/api': {
        // target: 'https://localhost:7181',
        target: 'https://localhost:5001',
        changeOrigin: true,             // Changes the origin header to match the target
        secure: false,                  // Set to false if using self-signed SSL certificates
        // rewrite: (path) => path.replace(/^\/api/, '')
      }
    }
  }
})

