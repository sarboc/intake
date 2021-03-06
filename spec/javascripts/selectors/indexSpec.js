import {buildSelector} from 'selectors'

describe('buildSelector', () => {
  it('accepts a single selector function which receives no args', () => {
    const selector = jasmine.createSpy('selector').and.returnValue('goodbye')
    const built = buildSelector(selector)

    expect(built('hello')).toEqual('goodbye')

    expect(selector).toHaveBeenCalled()
    expect(selector).not.toHaveBeenCalledWith('hello')
  })

  it('calls intermediate selectors', () => {
    const final = (a, b) => a + b
    const getFirst = (s) => s[0]
    const getLast = (s) => s[s.length - 1]
    const built = buildSelector(getFirst, getLast, final)

    expect(built('Hello, world!')).toEqual('H!')
  })

  it('can be called more than once', () => {
    const final = (a, b) => a + b
    const getFirst = (s) => s[0]
    const getLast = (s) => s[s.length - 1]
    const built = buildSelector(getFirst, getLast, final)

    expect(built('1 For the Money!')).toEqual('1!')
    expect(built('2 For The Show!')).toEqual('2!')
    expect(built('3 To Make Ready!')).toEqual('3!')
    expect(built('4 To Go!')).toEqual('4!')
  })

  it('passes multiple arguments to intermediate selectors', () => {
    const final = (sum, product) => ({sum, product})
    const add = (a, b) => a + b
    const mul = (a, b) => a * b
    const built = buildSelector(add, mul, final)

    expect(built(5, 7)).toEqual({sum: 12, product: 35})
    expect(built(3, 3)).toEqual({sum: 6, product: 9})
    expect(built(0, 1)).toEqual({sum: 1, product: 0})
  })
})
