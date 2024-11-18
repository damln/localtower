module.exports = {
  plugins: [
    require('postcss-import'),
    require('tailwindcss')({ config: './tailwind.config.js' }),
    require('autoprefixer'),
  ]
}
