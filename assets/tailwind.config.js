module.exports = {
  purge: [
    "../lib/**/*.ex",
    "../lib/**/*.leex",
    "../lib/**/*.eex",
    "./js/**/*.js",
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      backgroundColor: {
        'gold': '#e2c88f'
      },
      borderColor: {
        'gold': 'rgb(182, 140, 47)'
      },
      fontFamily: {
        'playfair': ["Playfair Display"],
        'libre': ["Libre Baskerville"]
      }
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
};
