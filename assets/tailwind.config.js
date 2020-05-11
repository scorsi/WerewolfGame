module.exports = {
    purge: {
        content: [
            "../**/*.html.eex",
            "../**/*.html.leex",
            "../**/views/**/*.ex",
            "../**/live/**/*.ex",
            "./js/**/*.js",
        ]
    },
    theme: {
        extend: {},
    },
    variants: ['responsive', 'group-hover', 'focus-within', 'first', 'last', 'odd', 'even', 'hover', 'focus', 'active', 'visited', 'disabled'],
    plugins: [
        require('tailwindcss-interaction-variants'),
    ],
};