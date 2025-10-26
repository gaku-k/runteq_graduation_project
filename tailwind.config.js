// tailwind.config.js
module.exports = {
  content: [
    "./app/views/**/*.{html,erb,haml,slim,jbuilder,turbo_stream}",
    "./app/javascript/**/*.js",
    "!./app/assets/builds/**/*",
    "!./app/assets/stylesheets/application.css",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
};