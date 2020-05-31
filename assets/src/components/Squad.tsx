/** @jsx jsx */
import { jsx } from '@emotion/core'
import { FunctionComponent } from 'react'

interface Props {
  readonly id: string
}

export const Squad: FunctionComponent<Props> = ({ id }) => <div>Game {id}</div>
