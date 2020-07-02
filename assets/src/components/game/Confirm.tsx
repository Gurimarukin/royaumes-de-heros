/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent, ReactNode, useCallback } from 'react'

import { ButtonUnderline, SecondaryButton } from '../Buttons'
import { ClickOutside } from '../ClickOutside'

export interface ConfirmProps {
  readonly hidden: boolean
  readonly message: ReactNode
  readonly onConfirm: () => void
}

export namespace ConfirmProps {
  export const empty: ConfirmProps = {
    hidden: true,
    message: null,
    onConfirm: () => {}
  }
}

interface Props {
  readonly hideConfirm: () => void
  readonly confirm: ConfirmProps
}

const SHOWN = 'shown'

export const Confirm: FunctionComponent<Props> = ({
  hideConfirm,
  confirm: { hidden, message, onConfirm }
}) => {
  const confirmAndHide = useCallback(() => {
    onConfirm()
    hideConfirm()
  }, [hideConfirm, onConfirm])

  return (
    <ClickOutside onClickOutside={hideConfirm}>
      <div css={styles.container} className={hidden ? undefined : SHOWN}>
        <h2 css={styles.title}>{message}</h2>
        <div css={styles.buttons}>
          <ButtonUnderline onClick={confirmAndHide}>Oui</ButtonUnderline>
          <SecondaryButton onClick={hideConfirm}>Non</SecondaryButton>
        </div>
      </div>
    </ClickOutside>
  )
}

const styles = {
  container: css({
    position: 'absolute',
    backgroundColor: 'rgba(0, 0, 0, 0.9)',
    border: '5px double goldenrod',
    boxShadow: '0 0 12px black',
    color: 'white',
    opacity: 0,
    visibility: 'hidden',
    transition: 'all 0.2s',

    [`&.${SHOWN}`]: {
      opacity: 1,
      visibility: 'visible'
    }
  }),

  title: css({
    fontSize: '1.4em',
    padding: '0.67em 1.33em'
  }),

  buttons: css({
    display: 'flex',
    justifyContent: 'center',
    padding: '0 1.67em',
    marginBottom: '1em',

    '& > button': {
      margin: '0 1em'
    }
  })
}
