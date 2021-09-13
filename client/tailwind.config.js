const colors = require('tailwindcss/colors')

module.exports = {
  mode: 'jit',
  purge: ['./public/index.html', './src/**/*.svelte'],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
  theme: {
    colors: {
      primary: '#A8D0DB',
      secondary: '#2B4570'
    }
  }
}
