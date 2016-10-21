# frozen_string_literal: true
require 'rails_helper'

describe Person do
  describe 'as_json' do
    it 'returns the attributes of a person as a hash' do
      attributes = {
        id: 1,
        first_name: 'Homer',
        last_name: 'Simpson',
        gender: 'male',
        date_of_birth: '05/29/1990',
        ssn: '123-23-1234',
        address: {
          id: 2,
          street_address: '123 fake st',
          city: 'Springfield',
          state: 'NY',
          zip: '12345'
        }
      }.with_indifferent_access
      expect(
        described_class.new(attributes).as_json
      ).to eq({
        id: 1,
        first_name: 'Homer',
        last_name: 'Simpson',
        gender: 'male',
        date_of_birth: '05/29/1990',
        ssn: '123-23-1234',
        address: {
          id: 2,
          street_address: '123 fake st',
          city: 'Springfield',
          state: 'NY',
          zip: '12345'
        }
      }.with_indifferent_access)
    end
  end
end