import _ from 'lodash'
import moment from 'moment-timezone'

export function dateFormatter(date) {
  if (_.isEmpty(date)) {
    return ''
  } else {
    return moment(date, 'YYYY-MM-DD').format('MM/DD/YYYY')
  }
}

export function dateTimeFormatter(date) {
  if (_.isEmpty(date)) {
    return ''
  } else {
    return moment(date, 'YYYY-MM-DDTh:mm:ss.fffZ').tz('America/Los_Angeles').format('MM/DD/YYYY h:mm A')
  }
}

export function dateRangeFormatter({start_date, end_date}) {
  return [
    dateFormatter(start_date),
    dateFormatter(end_date),
  ].filter((dateString) => Boolean(dateString))
    .join(' - ') || 'No Date'
}
