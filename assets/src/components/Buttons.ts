import styled from '@emotion/styled'

export const BaseButton = styled.button({
  fontFamily: 'inherit',
  fontSize: 'inherit',
  display: 'flex',
  flexDirection: 'column',
  lineHeight: 1,
  border: '3px solid',
  padding: '0.5em 0.6em 0.4em',
  transition: 'all 0.2s',

  backgroundColor: '#f6f0cd',
  color: '#4a3b20',
  borderColor: '#b59458',
  cursor: 'inherit',

  '&:not(:disabled)': {
    boxShadow: '0 0 8px -4px black'
  },

  '&[disabled]': {
    opacity: '0.5'
  }
})

export const ButtonUnderline = styled(BaseButton)({
  position: 'relative',

  '&::after': {
    content: `''`,
    position: 'absolute',
    bottom: '0.2em',
    left: '0.6em',
    width: 'calc(100% - 1.2em + 3px)',
    border: '1px solid',
    borderWidth: '1px 0',
    borderRadius: '50%',
    opacity: 0,
    transition: 'all 0.2s',

    borderColor: '#4a3b20'
  },

  '&:not([disabled]):hover::after': {
    opacity: 1
  }
})

export const SecondaryButton = styled(ButtonUnderline)({
  backgroundColor: 'dimgrey',
  borderColor: 'dimgrey',
  margin: '0 1em',
  color: 'white',

  '&::after': {
    borderColor: 'white',
    bottom: '0.1em'
  }
})
