const tailwind_config = require("../deps/moon/assets/tailwind.config.js");

tailwind_config.content = [
  "../lib/**/*.ex",
  "../lib/**/*.heex",
  "../lib/**/*.eex",
  "./js/**/*.js",

  "../deps/moon/lib/**/*.ex",
  "../deps/moon/lib/**/*.heex",
  "../deps/moon/lib/**/*.eex",
  "../deps/moon/assets/js/**/*.js",
];

module.exports = tailwind_config;




// const plugin = require("tailwindcss/plugin");
// module.exports = {
//   content: [
//     '../lib/**/*.ex',
//     '../lib/**/*.heex',
//     '../lib/**/*.eex',
//     './js/**/*.js',
//     '../deps/moon/lib/moon/**/*.ex',
//     '../deps/backoffice_base/**/*.ex',
//   ],
//   plugins: [
//     require('@tailwindcss/forms'),
//     require("tailwindcss-rtl"),
//     plugin(({ addComponents }) => {
//       addComponents({
//         ".btn-primary": {
//           color: "rgb(var(--goten))",
//           backgroundColor: `rgb(var(--piccolo))`,
//         },
//         ".btn-secondary": {
//           color: "rgb(var(--bulma))",
//           background: "none",
//           boxShadow: `inset 0 0 0 1px rgb(var(--trunks)/1)`,
//           "&:hover": {
//             boxShadow: `inset 0 0 0 1px rgb(var(--bulma))`,
//           },
//         },
//         ".btn-tertiary": {
//           color: "rgb(var(--goten))",
//           backgroundColor: "rgb(var(--hit))",
//         },
//         ".anim-error": {
//           transform: "translate3d(0, 0, 0)",
//           backfaceVisibility: "hidden",
//           perspective: "1000px",
//         },
//         ".anim-pulse": {
//           boxShadow: "0 0 0 0 rgb(var(--piccolo))",
//         },
//         ".input-number-clear": {
//           MozAppearance: "textfield",
//           "&::-webkit-inner-spin-button, &::-webkit-outer-spin-button": {
//             opacity: 0,
//           },
//         },
//         ".input-xl": {
//           "&:not(:focus):not([disabled])::placeholder": {
//             opacity: 0,
//           },
//           "&:not(:focus):not([disabled]):placeholder-shown + label": {
//             top: "50%",
//             marginTop: "-0.438rem",
//             fontSize: "1rem",
//             lineHeight: "1rem",
//           },
//         },
//         ".input-dt-shared": {
//           "&::-webkit-datetime-edit, &::-webkit-date-and-time-value": {
//             display: "block",
//             padding: 0,
//             height: "2.375rem",
//             lineHeight: "2.375rem",
//           },
//           "&::-webkit-date-and-time-value": {
//             paddingTop: "0.5rem",
//           },
//           "&::-webkit-calendar-picker-indicator": {
//             position: "absolute",
//           },
//         },
//         ".input-lg-dt-shared": {
//           "&::-webkit-datetime-edit": {
//             height: "2.875rem",
//             lineHeight: "2.875rem",
//           },
//           "&::-webkit-date-and-time-value": {
//             paddingTop: "0.625rem",
//           },
//         },
//         ".input-xl-dt-shared": {
//           "&::-webkit-datetime-edit": {
//             height: "3.5rem",
//             lineHeight: "3.5rem",
//           },
//           "&::-webkit-date-and-time-value": {
//             paddingTop: "1rem",
//           },
//         },
//         ".input-xl-dt-label": {
//           "&::-webkit-datetime-edit": {
//             height: "2.25rem",
//             lineHeight: "2.125rem",
//           },
//           "&::-webkit-date-and-time-value": {
//             paddingTop: 0,
//           },
//         },
//         ".input-d": {
//           "&::-webkit-calendar-picker-indicator": {
//             right: "0.875rem",
//           },
//         },
//         ".input-t": {
//           "&::-webkit-calendar-picker-indicator": {
//             right: "0.875rem",
//           },
//         },
//         ".input-d-rtl": {
//           //type === 'date' rtl
//           "&::-webkit-datetime-edit, &::-webkit-date-and-time-value": {
//             position: "absolute",
//             right: "0",
//           },
//           "&::-webkit-calendar-picker-indicator": {
//             left: "0.5rem",
//           },
//         },
//         ".input-t-rtl": {
//           //type === 'time' rtl
//           "&::-webkit-datetime-edit, &::-webkit-date-and-time-value": {
//             position: "absolute",
//             right: "0.5rem",
//           },
//           "&::-webkit-calendar-picker-indicator": {
//             left: "0.5rem",
//           },
//         },
//         ".input-dt-local-rtl": {
//           //type === 'datetime-local' rtl
//           "&::-webkit-datetime-edit, &::-webkit-date-and-time-value": {
//             position: "absolute",
//             right: "0",
//           },
//           "&::-webkit-calendar-picker-indicator": {
//             left: "0.5rem",
//           },
//         },
//         ".input-rsb-hidden": {
//           "&:not(:hover):not(:focus):not(:invalid)": {
//             clipPath: `inset(calc(var(--border-i-width) * -1) 0.125rem calc(var(--border-i-width) * -1) 0)`,
//           },
//         },
//         ".input-lsb-hidden": {
//           "&:not(:hover):not(:focus):not(:invalid)": {
//             clipPath: `inset(calc(var(--border-i-width) * -1) 0 calc(var(--border-i-width) * -1) 0.125rem)`,
//           },
//         },
//         ".input-tbb-hidden": {
//           "&:not(:hover):not(:focus):not(:invalid)": {
//             clipPath: `inset(0.125rem calc(var(--border-i-width) * -1) 0 calc(var(--border-i-width) * -1))`,
//           },
//         },
//         ".input-bbb-hidden": {
//           "&:not(:hover):not(:focus):not(:invalid)": {
//             clipPath: `inset(0 calc(var(--border-i-width) * -1) 0.125rem calc(var(--border-i-width) * -1))`,
//           },
//         },
//         ".brcrumb-li": {
//           "& a, & span": {
//             padding: "0.5rem",
//           },
//         },
//       });
//     }),
//   ],
//   presets: [require('./ds-moon-preset')],
// };