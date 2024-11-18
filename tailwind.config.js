const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './app/views/**/*.{erb,haml,html,slim}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.{js,jsx,ts,tsx}',
    './app/components/**/*.{erb,haml,html,slim,rb,js,jsx,ts,tsx}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Circular', ...defaultTheme.fontFamily.sans]
      },
      colors: {
        localtower: {
          50: '#f9f9f9',    // Lightest shade
          100: '#ebebeb',
          200: '#d6d6d6',
          300: '#b8b8b8',
          400: '#909090',
          450: '#6e6e6e',
          500: '#313131',    // From your colors
          600: '#1c1c1c',    // From your colors
          700: '#171717',    // From your colors
          800: '#0f0f0f',    // From your colors
          900: '#080808'     // Darkest shade
        }
      }
    },
  },
  plugins: [],
}
