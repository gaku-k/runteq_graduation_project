// tailwind.config.js
export default {
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