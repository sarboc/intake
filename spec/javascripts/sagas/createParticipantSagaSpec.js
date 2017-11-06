import 'babel-polyfill'
import {takeEvery, put, call, select} from 'redux-saga/effects'
import {post} from 'utils/http'
import {
  createParticipant,
  createParticipantSaga,
} from 'sagas/createParticipantSaga'
import {CREATE_PERSON} from 'actions/personCardActions'
import {getScreeningIdValueSelector} from 'selectors/screeningSelectors'
import * as screeningActions from 'actions/screeningActions'
import * as personCardActions from 'actions/personCardActions'

describe('createParticipantSaga', () => {
  it('creates participant on CREATE_PERSON', () => {
    const gen = createParticipantSaga()
    expect(gen.next().value).toEqual(takeEvery(CREATE_PERSON, createParticipant))
  })
})

describe('createParticipant', () => {
  const participant = {first_name: 'Michael'}
  const action = personCardActions.createParticipant(participant)

  it('creates and puts participant and fetches relationships and history', () => {
    const gen = createParticipant(action)
    expect(gen.next().value).toEqual(call(post, '/api/v1/participants', participant))
    expect(gen.next(participant).value).toEqual(
      put(personCardActions.createParticipantSuccess(participant))
    )
    expect(gen.next().value).toEqual(
      select(getScreeningIdValueSelector)
    )
    const screeningId = '444'
    expect(gen.next(screeningId).value).toEqual(
      put(screeningActions.fetchRelationships(screeningId))
    )
    expect(gen.next(screeningId).value).toEqual(
      put(screeningActions.fetchHistoryOfInvolvements(screeningId))
    )
  })

  it('puts errors when errors are thrown', () => {
    const gen = createParticipant(action)
    expect(gen.next().value).toEqual(call(post, '/api/v1/participants', participant))
    const error = {responseJSON: 'some error'}
    expect(gen.throw(error).value).toEqual(
      put(personCardActions.createParticipantFailure('some error'))
    )
  })
})
