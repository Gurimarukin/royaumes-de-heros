/** @jsx jsx */
import { css, jsx } from '@emotion/core'
import * as D from 'io-ts/Decoder'
import { Fragment, FunctionComponent, useCallback, useContext, useState } from 'react'

import { CsrfTokenContext } from '../contexts/CsrfTokenContext'
import { HistoryContext } from '../contexts/HistoryContext'
import { UserContext } from '../contexts/UserContext'
import { useChannel } from '../hooks/useChannel'
import { AsyncState } from '../models/AsyncState'
import { ChannelError } from '../models/ChannelError'
import { SquadId } from '../models/SquadId'
import { SquadsEvent } from '../models/SquadsEvent'
import { SquadShort } from '../models/SquadShort'
import { Either, Future, IO, Maybe, flow, pipe } from '../utils/fp'
import { HttpUtils } from '../utils/HttpUtils'
import { PhoenixUtils } from '../utils/PhoenixUtils'
import { ButtonUnderline } from './Buttons'
import { ClickOutside } from './ClickOutside'
import { Error } from './Error'
import { Squads } from './home/Squads'
import { Check, Pencil } from './icons'
import { Loading } from './Loading'
import { Router } from './Router'

export const Home: FunctionComponent = () => {
  const { user } = useContext(UserContext)

  const [state, setState] = useState<AsyncState<ChannelError, SquadShort[]>>(AsyncState.Loading)

  const onJoinSuccess = useCallback(
    PhoenixUtils.handleResponse(PhoenixUtils.decodeBody(D.array(SquadShort.codec).decode))(
      flow(AsyncState.Success, setState)
    ),
    []
  )

  const [, channel] = useChannel(user.token, 'squads', { onJoinSuccess, onUpdate: onJoinSuccess })
  const pushEvent = useCallback(
    (event: SquadsEvent): Future<Either<unknown, unknown>> =>
      pipe(
        () => channel.push(event[0], (event[1] as unknown) as object),
        PhoenixUtils.pushToFuture
      ),
    [channel]
  )

  const onLoading = useCallback((): JSX.Element => <Loading />, [])

  const onError = useCallback((error: ChannelError): JSX.Element => <Error error={error} />, [])

  const onSuccess = useCallback(
    (squads: SquadShort[]): JSX.Element => <SuccesSquads pushEvent={pushEvent} squads={squads} />,
    [pushEvent]
  )

  return pipe(state, AsyncState.fold({ onLoading, onError, onSuccess }))
}

const idCodec = D.type({
  id: SquadId.codec
})

interface Props {
  readonly pushEvent: (event: SquadsEvent) => Future<Either<unknown, unknown>>
  readonly squads: SquadShort[]
}

const SuccesSquads: FunctionComponent<Props> = ({ pushEvent, squads }) => {
  const history = useContext(HistoryContext)
  const { user, setUser } = useContext(UserContext)

  const handleInputMount = useCallback((elt: HTMLInputElement | null) => elt?.select(), [])

  const [edit, setEdit] = useState(false)
  const startEditing = useCallback(() => setEdit(true), [])

  const [userName, setUserName] = useState(user.name)
  const handleChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => setUserName(e.target.value),
    []
  )

  const undoChanges = useCallback(() => {
    setEdit(false)
    setUserName(user.name)
  }, [user.name])

  const validUserName = pipe(
    Maybe.some(userName.trim()),
    Maybe.filter(_ => _ !== '')
  )

  const csrfToken = useContext(CsrfTokenContext)
  const submitName = useCallback(() => {
    pipe(
      validUserName,
      Maybe.map(name => {
        setEdit(false)
        if (name !== user.name) {
          pipe(
            HttpUtils.post(csrfToken)('/rename', name),
            Future.chain(_ =>
              _.ok
                ? pipe(
                    Future.apply(() => _.text()),
                    Future.map(name => {
                      setUser(_ => ({ ..._, name }))
                      setUserName(name)
                    })
                  )
                : pipe(
                    IO.apply(() => setUserName(user.name)),
                    Future.fromIOEither
                  )
            ),
            Future.runUnsafe
          )
        }
      })
    )
  }, [csrfToken, setUser, user.name, validUserName])

  const handleKeyUp = useCallback(
    (e: React.KeyboardEvent) => {
      if (e.key === 'Enter') submitName()
    },
    [submitName]
  )

  const createGame = useCallback(() => {
    pipe(
      SquadsEvent.Create,
      pushEvent,
      Future.map(
        Either.fold(
          _ => {},
          flow(
            idCodec.decode,
            Either.map(({ id }) => history.push(Router.routes.squad(id)))
          )
        )
      ),
      Future.runUnsafe
    )
  }, [history, pushEvent])

  return (
    <div css={styles.container}>
      <div css={styles.header}>
        <h1>Royaumes de Héros</h1>
        <div css={styles.pseudo}>
          <span>Pseudalité :</span>
          {edit ? (
            <ClickOutside onClickOutside={undoChanges}>
              <div css={styles.userNameInputContainer}>
                <span css={styles.userNameInputHitbox}>{userName === '' ? ' ' : userName}</span>
                <input
                  ref={handleInputMount}
                  type='text'
                  value={userName}
                  onChange={handleChange}
                  onKeyUp={handleKeyUp}
                  autoFocus={true}
                  css={styles.userNameInput}
                />
              </div>
              <button
                disabled={Maybe.isNone(validUserName)}
                onClick={submitName}
                css={styles.iconBtn}
              >
                <Check />
              </button>
            </ClickOutside>
          ) : (
            <Fragment>
              <span css={styles.userName}>{userName}</span>
              <button css={styles.iconBtn} onClick={startEditing}>
                <Pencil />
              </button>
            </Fragment>
          )}
        </div>
        <ButtonUnderline onClick={createGame}>Nouvelle partie</ButtonUnderline>
      </div>

      <div css={styles.squads}>
        {squads.length === 0 ? (
          <div css={styles.noSquads}>Pas de partie en cours.</div>
        ) : (
          <Squads squads={squads} />
        )}
      </div>
    </div>
  )
}

const styles = {
  container: css({
    width: '100vw',
    height: '100vh',
    backgroundImage: "url('/images/bg.jpg')",
    backgroundSize: '100% 100%',
    overflowY: 'auto',
    color: 'bisque'
  }),

  header: css({
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    backgroundColor: 'darkslateblue',
    padding: '2em 0 1em'
  }),

  pseudo: css({
    fontSize: '1.2em',
    margin: '2em 0',
    display: 'flex',
    alignItems: 'center'
  }),

  userName: css({
    display: 'inline-block',
    margin: '0 0.33em',
    padding: '0.33em',
    fontWeight: 'bold',
    lineHeight: 'normal'
  }),

  userNameInputContainer: css({
    position: 'relative',
    margin: '0 0.33em',
    fontWeight: 'bold'
  }),

  userNameInputHitbox: css({
    display: 'inline-block',
    visibility: 'hidden',
    fontWeight: 'inherit',
    padding: '0.33em',
    lineHeight: 'normal'
  }),

  userNameInput: css({
    position: 'absolute',
    left: 0,
    top: 0,
    right: 0,
    width: '100%',
    fontFamily: 'inherit',
    fontSize: '1em',
    fontWeight: 'inherit',
    color: 'inherit',
    padding: '0.33em',
    backgroundColor: 'transparent',
    border: 'none',
    outline: '1px solid bisque',
    boxShadow: '0 0 2px 1px bisque'
  }),

  iconBtn: css({
    cursor: 'inherit',
    display: 'inline',
    border: 'none',
    padding: '0.33em',
    backgroundColor: 'unset',
    color: 'inherit',
    fontSize: '1em',
    width: '1.67em',
    height: '1.67em',
    borderRadius: '2px',
    transition: 'all 0.2s',

    '&:not(:disabled):hover': {
      backgroundColor: 'rgba(0, 0, 0, 0.4)'
    },

    '&:disabled': {
      color: '#827463'
    }
  }),

  squads: css({
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    paddingTop: '2em'
  }),

  noSquads: css({
    textAlign: 'center'
  })
}
