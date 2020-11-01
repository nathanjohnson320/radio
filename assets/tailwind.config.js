const defaultTheme = require('tailwindcss/defaultTheme');

module.exports = {
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      spacing: {
        '86': '21.5rem',
        '125': '31.25rem'
      },
    },
    customForms: theme => ({
      default: {
        'input, textarea, multiselect, checkbox, radio, select': {
          '&:focus': {
            boxShadow: theme('colors.blue.100'),
            borderColor: theme('colors.blue.400'),
          }
        },
        'checkbox, radio': {
          color: theme('colors.blue.400'),
        }
      }
    })
  },
  variants: {
    borderWidth: ['responsive', 'first', 'hover', 'focus'],
    backgroundColor: ['responsive', 'hover', 'focus', 'odd', 'even'],
    borderColor: ['responsive', 'hover', 'focus', 'odd', 'even'],
    margin: ['responsive', 'first'],
    opacity: ['responsive', 'hover', 'focus', 'disabled'],
  },
  plugins: [
    require('@tailwindcss/ui'),
  ],
  purge: {
    enabled: false,
    content: [
      '../lib/**/*.leex',
      '../lib/**/*.eex'
    ],
  },
  future: {
    removeDeprecatedGapUtilities: true,
    purgeLayersByDefault: true,
  },
}
