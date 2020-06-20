/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent } from 'react'

import { Link } from '../Link'
import { Router } from '../Router'
import { Stage } from '../../models/Stage'
import { SquadId } from '../../models/SquadId'
import { SquadShort } from '../../models/SquadShort'

interface Props {
  readonly squads: SquadShort[]
}

export const Squads: FunctionComponent<Props> = ({ squads }) => (
  <table css={styles.container}>
    <thead>
      <tr css={styles.header}>
        <th css={styles.stage}>Phase</th>
        <th css={styles.nPlayers}>Joueurs</th>
        <th css={styles.squadJoin} />
      </tr>
    </thead>
    <tbody>
      {squads.map(squad => (
        <tr key={SquadId.unwrap(squad.id)} css={styles.squad}>
          <td css={styles.stage}>{stageLabel(squad.stage)}</td>
          <td css={styles.nPlayers}>{squad.n_players}</td>
          <td css={styles.squadJoin}>
            {squad.stage === 'lobby' ? (
              <Link to={Router.routes.squad(squad.id)} css={styles.squadJoinLink}>
                rejoindre
              </Link>
            ) : null}
          </td>
        </tr>
      ))}
    </tbody>
  </table>
)

function stageLabel(stage: Stage): string {
  switch (stage) {
    case 'lobby':
      return 'Salon'
    case 'game':
      return 'En partie'
  }
}

const styles = {
  container: css({
    width: '1100px',
    fontSize: '1.1em',
    display: 'flex',
    flexDirection: 'column',

    '& td, & th': {
      padding: '0.67em 0.33em'
    }
  }),

  header: css({
    width: '100%',
    display: 'flex',
    borderBottom: '3px double darkgoldenrod',
    fontWeight: 'bold'
  }),

  squad: css({
    display: 'flex',

    '&:nth-of-type(2n)': {
      backgroundColor: 'rgba(245, 222, 179, 0.3)'
    }
  }),

  stage: css({
    flex: '1 0 0',
    textAlign: 'left'
  }),

  nPlayers: css({
    flex: '1 0 0',
    textAlign: 'center'
  }),

  squadJoin: css({
    flex: '1 0 0',
    textAlign: 'right'
  }),

  squadJoinLink: css({
    color: 'inherit',
    cursor: 'inherit',
    padding: '0.1em 0.2em',
    transition: 'all 0.2s',

    '&:hover': {
      backgroundColor: 'rgba(255, 255, 255, 0.2)'
    }
  })
}
