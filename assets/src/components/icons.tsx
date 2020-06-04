/** @jsx jsx */
import { css, jsx, keyframes } from '@emotion/core'

import { FunctionComponent } from 'react'

type SVGComponent = FunctionComponent<Props>

interface Props {
  className?: string
}

export const Coin: SVGComponent = ({ className }) => (
  <svg
    focusable='false'
    xmlns='http://www.w3.org/2000/svg'
    viewBox='0 0 512 512'
    css={styles.base}
    className={className}
  >
    <path
      fill='currentColor'
      d='M0 320c0 27.77 18 53.37 48 74.33V330c-18.85-12-35.4-25.36-48-40.38zm256 32c141.33 0 256-64.44 256-144S397.33 64 256 64 0 128.44 0 208s114.67 144 256 144zM80 412.51c27.09 12.89 59.66 22.81 96 28.8V377c-35.39-6-67.81-15.88-96-29zm384-18.18c30.05-21 48-46.56 48-74.33v-30.37c-12.6 15-29.15 28.37-48 40.38zm-128 47c36.34-6 68.91-15.91 96-28.8V348c-28.19 13.12-60.61 23-96 29zM208 381.2v64.09c15.62 1.51 31.49 2.71 48 2.71s32.38-1.2 48-2.71V381.2a477.2 477.2 0 0 1-48 2.8 477.2 477.2 0 0 1-48-2.8z'
      className=''
    />
  </svg>
)

export const Skull: SVGComponent = ({ className }) => (
  <svg
    focusable='false'
    xmlns='http://www.w3.org/2000/svg'
    viewBox='0 0 512 512'
    css={styles.base}
    className={className}
  >
    <g className='fa-group'>
      <path
        fill='currentColor'
        d='M256 0C114.6 0 0 100.3 0 224c0 70.1 36.9 132.6 94.5 173.7 9.6 6.9 15.2 18.1 13.5 29.9l-9.4 66.2a15.87 15.87 0 0 0 13.37 18 16.49 16.49 0 0 0 2.33.17H192V456a8 8 0 0 1 8-8h16a8 8 0 0 1 8 8v56h64v-56a8 8 0 0 1 8-8h16a8 8 0 0 1 8 8v56h77.7a15.87 15.87 0 0 0 15.87-15.87 16.49 16.49 0 0 0-.17-2.33l-9.4-66.2c-1.7-11.7 3.8-23 13.5-29.9C475.1 356.6 512 294.1 512 224 512 100.3 397.4 0 256 0zm-96 320a64 64 0 1 1 64-64 64 64 0 0 1-64 64zm192 0a64 64 0 1 1 64-64 64 64 0 0 1-64 64z'
        className='primary'
      />
      <path
        fill='currentColor'
        d='M160 192a64 64 0 1 0 64 64 64 64 0 0 0-64-64zm192 0a64 64 0 1 0 64 64 64 64 0 0 0-64-64z'
        className='secondary'
      />
    </g>
  </svg>
)

export const Swords: SVGComponent = ({ className }) => (
  <svg
    focusable='false'
    xmlns='http://www.w3.org/2000/svg'
    viewBox='0 0 512 512'
    css={styles.base}
    className={className}
  >
    <path
      fill='currentColor'
      d='M309.37 389.38l80-80L93.33 13.33 15.22.14C6.42-1.12-1.12 6.42.14 15.22l13.2 78.11 296.03 296.05zm197.94 72.68L448 402.75l31.64-59.03c3.33-6.22 2.2-13.88-2.79-18.87l-17.54-17.53c-6.25-6.25-16.38-6.25-22.63 0L307.31 436.69c-6.25 6.25-6.25 16.38 0 22.62l17.53 17.54a16 16 0 0 0 18.87 2.79L402.75 448l59.31 59.31c6.25 6.25 16.38 6.25 22.63 0l22.62-22.62c6.25-6.25 6.25-16.38 0-22.63zm-8.64-368.73l13.2-78.11c1.26-8.8-6.29-16.34-15.08-15.08l-78.11 13.2-140.05 140.03 80 80L498.67 93.33zm-345.3 185.3L100 332l-24.69-24.69c-6.25-6.25-16.38-6.25-22.62 0l-17.54 17.53a15.998 15.998 0 0 0-2.79 18.87L64 402.75 4.69 462.06c-6.25 6.25-6.25 16.38 0 22.63l22.62 22.62c6.25 6.25 16.38 6.25 22.63 0L109.25 448l59.03 31.64c6.22 3.33 13.88 2.2 18.87-2.79l17.53-17.54c6.25-6.25 6.25-16.38 0-22.62L180 412l53.37-53.37-80-80z'
    />
  </svg>
)

const styles = {
  base: css({
    height: '1em',

    '& .secondary': {
      opacity: 0.7
    }
  }),

  spin: css({
    animation: `${spin()} 2s linear infinite`
  })
}

function spin() {
  return keyframes({
    '0%': { transform: 'rotate(0deg)' },
    '100%': { transform: 'rotate(360deg)' }
  })
}
