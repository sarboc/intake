# frozen_string_literal: true

require 'rails_helper'

feature 'Race & Ethnicity' do
  let(:marge) do
    FactoryBot.create(
      :participant,
      middle_name: 'Jacqueline',
      races: [{ race: 'Asian', race_detail: 'Hmong' }],
      ethnicity: { hispanic_latino_origin: 'Yes', ethnicity_detail: ['Mexican'] }
    )
  end
  let(:homer) do
    FactoryBot.create(
      :participant,
      middle_name: 'Jay',
      races: [{ race: 'Unknown', race_detail: nil }],
      ethnicity: { hispanic_latino_origin: 'Declined to answer', ethnicity_detail: [] }
    )
  end
  let(:screening) do
    {
      id: '1',
      incident_address: {},
      cross_reports: [],
      allegations: [],
      participants: [marge.as_json.symbolize_keys, homer.as_json.symbolize_keys]
    }
  end

  before do
    stub_request(:get, ferb_api_url(FerbRoutes.intake_screening_path(screening[:id])))
      .and_return(json_body(screening.to_json, status: 200))
    stub_empty_history_for_screening(screening)
    stub_empty_relationships
  end

  context 'when changing to abandoned, unknown, declined' do
    it 'disables and unselects the other checkboxes' do
      visit edit_screening_path(id: screening[:id])
      within edit_participant_card_selector(marge.id) do
        within '#race' do
          expect(find('input[value="Asian"]')).to be_checked
          expect(page).to have_select(
            "participant-#{marge.id}-Asian-race-detail", selected: 'Hmong'
          )
          find('label', text: 'Unknown').click
          expect(find('input[value="Unknown"]')).to be_checked
          expect(find('input[value="Asian"]')).to_not be_checked
          expect(find('input[value="Asian"]')).to be_disabled
          expect(page).to_not have_select(
            "participant-#{marge.id}-Asian-race-detail", selected: 'Hmong'
          )
        end
        within 'fieldset', text: 'Hispanic/Latino Origin' do
          expect(find('input[value="Yes"]')).to be_checked
          expect(page).to have_select('', selected: 'Mexican')
          expect(find('input[value="Declined to answer"]')).to be_disabled
          find('label', text: 'Yes').click
          find('label', text: 'Declined to answer').click
          expect(find('input[value="Declined to answer"]')).to be_checked
          expect(find('input[value="Yes"]')).to be_disabled
          expect(page).to_not have_select('', selected: 'Mexican')
        end

        marge.races = [{ race: 'Unknown', race_detail: nil }]
        marge.ethnicity = { hispanic_latino_origin: 'Declined to answer', ethnicity_detail: [] }
        stub_request(:put,
          ferb_api_url(FerbRoutes.screening_participant_path(screening[:id], marge.id)))
          .and_return(json_body(marge.to_json, status: 200))

        click_button 'Save'
        expect(
          a_request(:put,
            ferb_api_url(FerbRoutes.screening_participant_path(screening[:id], marge.id)))
          .with(body: hash_including(
            'races' => array_including(
              hash_including(
                'race' => 'Unknown',
                'race_detail' => nil
              )
            ),
            'ethnicity' => hash_including(
              'ethnicity_detail' => [],
              'hispanic_latino_origin' => 'Declined to answer'
            )
          ))
        ).to have_been_made
      end
      within show_participant_card_selector(marge.id) do
        within '.card-body' do
          expect(page).to have_content('Unknown')
          expect(page).to have_content('Declined to answer')
        end
      end
    end
  end

  context 'when changing to race or ethnicity' do
    it 'enables and allows selection of the other checkboxes' do
      visit edit_screening_path(id: screening[:id])
      within edit_participant_card_selector(homer.id) do
        within '#race' do
          expect(find('input[value="Unknown"]')).to be_checked
          expect(find('input[value="Asian"]')).to be_disabled
          find('label', text: 'Unknown').click
          find('label', text: 'Asian').click
          select 'Hmong', from: "participant-#{homer.id}-Asian-race-detail"
        end
        within 'fieldset', text: 'Hispanic/Latino Origin' do
          expect(find('input[value="Declined to answer"]')).to be_checked
          expect(find('input[value="Yes"]')).to be_disabled
          find('label', text: 'Declined to answer').click
          find('label', text: 'Yes').click
          select 'Mexican', from: ''
        end

        homer.races = [{ race: 'Asian', race_detail: 'Hmong' }]
        homer.ethnicity = { hispanic_latino_origin: 'Yes', ethnicity_detail: ['Mexican'] }
        stub_request(:put,
          ferb_api_url(FerbRoutes.screening_participant_path(screening[:id], homer.id)))
          .and_return(json_body(homer.to_json, status: 200))

        click_button 'Save'
        expect(
          a_request(:put,
            ferb_api_url(FerbRoutes.screening_participant_path(screening[:id], homer.id)))
          .with(body: hash_including(
            'races' => array_including(
              hash_including(
                'race' => 'Asian',
                'race_detail' => 'Hmong'
              )
            ),
            'ethnicity' => hash_including(
              'ethnicity_detail' => ['Mexican'],
              'hispanic_latino_origin' => 'Yes'
            )
          ))
        ).to have_been_made
      end
      within show_participant_card_selector(homer.id) do
        within '.card-body' do
          expect(page).to have_content('Mexican - Yes')
          expect(page).to have_content('Asian - Hmong')
        end
      end
    end
  end
end
