# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

feature 'show allegations' do
  scenario 'editing existing allegations' do
    marge = FactoryGirl.create(:participant, first_name: 'Marge', roles: ['Perpetrator'])
    lisa = FactoryGirl.create(:participant, first_name: 'Lisa', roles: ['Victim'])
    homer = FactoryGirl.create(:participant, first_name: 'Homer', roles: ['Perpetrator'])
    screening = FactoryGirl.create(
      :screening,
      participants: [marge, homer, lisa]
    )
    allegation = FactoryGirl.create(
      :allegation,
      victim_id: lisa.id,
      perpetrator_id: marge.id,
      screening_id: screening.id,
      allegation_types: ['General neglect', 'Severe neglect']
    )
    screening.allegations << allegation

    stub_request(:get, api_screening_path(screening.id))
      .and_return(json_body(screening.to_json, status: 200))

    visit screening_path(id: screening.id)

    within '#allegations-card.card.show' do
      within 'thead' do
        expect(page).to have_content('Alleged Victim/Children')
        expect(page).to have_content('Alleged Perpetrator')
        expect(page).to have_content('Allegation(s)')
      end

      within 'tbody' do
        expect(page).to_not have_content('Homer')

        table_rows = page.all('tr')

        within table_rows[0] do
          expect(page).to have_content('Marge')
          expect(page).to have_content('Lisa')
          expect(page).to have_content('General neglect')
        end

        within table_rows[1] do
          expect(page).to have_content('Marge')
          expect(page).to have_content('Lisa')
          expect(page).to have_content('Severe neglect')
        end
      end
    end

    within '#allegations-card.card.show' do
      click_link 'Edit allegations'
    end

    within '#allegations-card.card.edit' do
      within 'tbody' do
        table_rows = page.all('tr')

        within table_rows[0] do
          expect(page).to have_content('Marge')
          expect(page).to have_content('Lisa')
          has_react_select_field(
            "allegations_#{lisa.id}_#{marge.id}",
            with: ['General neglect', 'Severe neglect']
          )
        end

        within table_rows[1] do
          expect(page).to have_no_content('Lisa')
          expect(page).to have_content('Homer')

          select_field_id = "allegations_#{lisa.id}_#{homer.id}"
          has_react_select_field(select_field_id, with: [])
          fill_in_react_select(select_field_id, with: ['Exploitation'])
        end
      end

      click_button 'Save'
    end

    new_allegation = FactoryGirl.build(
      :allegation,
      victim_id: lisa.id,
      perpetrator_id: homer.id,
      screening_id: screening.id,
      allegation_types: ['Exploitation']
    )
    screening.allegations << new_allegation

    expect(
      a_request(:put, api_screening_path(screening.id))
      .with(json_body(as_json_without_root_id(screening).merge('participants' => [])))
    ).to have_been_made
  end

  scenario 'deleting a participant from a screening removes related allegations' do
    marge = FactoryGirl.create(:participant, first_name: 'Marge', roles: ['Perpetrator'])
    lisa = FactoryGirl.create(:participant, first_name: 'Lisa', roles: ['Victim'])
    homer = FactoryGirl.create(:participant, first_name: 'Homer', roles: ['Perpetrator'])
    screening = FactoryGirl.create(
      :screening,
      participants: [marge, homer, lisa]
    )
    allegation = FactoryGirl.create(
      :allegation,
      victim_id: lisa.id,
      perpetrator_id: marge.id,
      screening_id: screening.id,
      allegation_types: ['General neglect']
    )
    screening.allegations << allegation

    stub_request(:get, api_screening_path(screening.id))
      .and_return(json_body(screening.to_json, status: 200))

    visit screening_path(id: screening.id)

    within '#allegations-card.card.show' do
      within 'tbody tr' do
        expect(page).to have_content('Marge')
        expect(page).to have_content('Lisa')
        expect(page).to have_content('General neglect')
      end
    end

    stub_request(:delete, api_participant_path(marge.id))
      .and_return(status: 204, headers: { 'Content-Type' => 'application/json' })

    within show_participant_card_selector(marge.id) do
      click_button 'Delete participant'
    end

    within '#allegations-card.card.show' do
      within 'tbody', visible: false do
        expect(page).to_not have_content('Marge')
        expect(page).to_not have_content('Lisa')
        expect(page).to_not have_content('General neglect')
      end

      click_link 'Edit allegations'
    end

    within '#allegations-card.card.edit' do
      within 'tbody' do
        expect(page).to have_content('Lisa')
        expect(page).to have_content('Homer')
        expect(page).to_not have_content('Marge')
        expect(page).to_not have_content('General neglect')
      end
    end
  end

  scenario 'removing participant role, re-adding it does not show deleted allegations' do
    marge = FactoryGirl.create(
      :participant,
      first_name: 'Marge',
      roles: ['Perpetrator', 'Anonymous Reporter']
    )
    lisa = FactoryGirl.create(:participant, first_name: 'Lisa', roles: ['Victim'])
    screening = FactoryGirl.create(
      :screening,
      participants: [marge, lisa]
    )
    allegation = FactoryGirl.create(
      :allegation,
      victim_id: lisa.id,
      perpetrator_id: marge.id,
      screening_id: screening.id,
      allegation_types: ['General neglect']
    )
    screening.allegations << allegation
    stub_request(:get, api_screening_path(screening.id))
      .and_return(json_body(screening.to_json, status: 200))

    visit screening_path(id: screening.id)

    within '#allegations-card.card.show' do
      within 'tbody tr' do
        expect(page).to have_content('Marge')
        expect(page).to have_content('Lisa')
        expect(page).to have_content('General neglect')
      end
    end

    within show_participant_card_selector(marge.id) do
      click_link 'Edit participant'
    end

    marge.roles = ['Anonymous Reporter']
    stub_request(:put, api_participant_path(marge.id))
      .with(json_body(as_json_without_root_id(marge)))
      .and_return(json_body(marge.to_json, status: 200))

    screening.allegations = []
    screening.participants = [lisa, marge]
    stub_request(:get, api_screening_path(screening.id))
      .and_return(json_body(screening.to_json, status: 200))

    within edit_participant_card_selector(marge.id) do
      remove_react_select_option('Role', 'Perpetrator')
      click_button 'Save'
    end

    within '#allegations-card.card.show' do
      within 'tbody', visible: false do
        expect(page).to_not have_content('Marge')
        expect(page).to_not have_content('Lisa')
        expect(page).to_not have_content('General neglect')
      end
    end

    within show_participant_card_selector(marge.id) do
      click_link 'Edit participant'
    end

    marge.roles = ['Anonymous Reporter', 'Perpetrator']
    stub_request(:put, api_participant_path(marge.id))
      .with(json_body(as_json_without_root_id(marge)))
      .and_return(json_body(marge.to_json, status: 200))

    screening.participants = [lisa, marge]
    stub_request(:get, api_screening_path(screening.id))
      .and_return(json_body(screening.to_json, status: 200))

    within edit_participant_card_selector(marge.id) do
      fill_in_react_select('Role', with: 'Perpetrator')
      click_button 'Save'
    end

    within '#allegations-card.card.show' do
      within 'tbody', visible: false do
        expect(page).to_not have_content('Marge')
        expect(page).to_not have_content('Lisa')
        expect(page).to_not have_content('General neglect')
      end

      click_link 'Edit allegations'
    end

    within '#allegations-card.card.edit' do
      within 'tbody tr' do
        expect(page).to have_content('Marge')
        expect(page).to have_content('Lisa')
        has_react_select_field "allegations_#{lisa.id}_#{marge.id}", with: []
      end
    end
  end

  scenario 'saving another card will not persist changes to allegations' do
    marge = FactoryGirl.create(:participant, first_name: 'Marge', roles: ['Perpetrator'])
    lisa = FactoryGirl.create(:participant, first_name: 'Lisa', roles: ['Victim'])
    screening = FactoryGirl.create(:screening, participants: [marge, lisa])
    stub_request(:get, api_screening_path(screening.id))
      .and_return(json_body(screening.to_json, status: 200))

    visit screening_path(id: screening.id)

    screening.name = 'Hello'
    stub_request(:put, api_screening_path(screening.id))
      .and_return(json_body(screening.to_json, status: 200))

    within '#allegations-card.card.show' do
      click_link 'Edit allegations'
    end

    within '#allegations-card.card.edit' do
      fill_in_react_select "allegations_#{lisa.id}_#{marge.id}", with: ['General neglect']
    end

    within '#screening-information-card.card.show' do
      click_link 'Edit screening information'
    end

    within '#screening-information-card.card.edit' do
      fill_in 'Title/Name of Screening', with: 'Hello'
      click_button 'Save'
    end

    expect(
      a_request(:put, api_screening_path(screening.id))
      .with(json_body(as_json_without_root_id(screening).merge('participants' => [])))
    ).to have_been_made
  end

  scenario 'only allegations with allegation types are sent to the API' do
    marge = FactoryGirl.create(:participant, first_name: 'Marge', roles: ['Perpetrator'])
    lisa = FactoryGirl.create(:participant, first_name: 'Lisa', roles: ['Victim'])
    homer = FactoryGirl.create(:participant, first_name: 'Homer', roles: ['Perpetrator'])
    screening = FactoryGirl.create(
      :screening,
      participants: [marge, homer, lisa]
    )

    stub_request(:get, api_screening_path(screening.id))
      .and_return(json_body(screening.to_json, status: 200))

    visit screening_path(id: screening.id)

    within '#allegations-card.card.show' do
      click_link 'Edit allegations'
    end

    within '#allegations-card.card.edit' do
      within 'tbody' do
        table_rows = page.all('tr')

        within table_rows[0] do
          expect(page).to have_content('Marge')
          expect(page).to have_content('Lisa')
          has_react_select_field("allegations_#{lisa.id}_#{marge.id}", with: [])
        end

        within table_rows[1] do
          expect(page).to have_no_content('Lisa')
          expect(page).to have_content('Homer')

          select_field_id = "allegations_#{lisa.id}_#{homer.id}"
          has_react_select_field(select_field_id, with: [])
          fill_in_react_select(select_field_id, with: ['Exploitation'])
        end
      end
      click_button 'Save'
    end

    new_allegation = FactoryGirl.build(
      :allegation,
      victim_id: lisa.id,
      perpetrator_id: homer.id,
      screening_id: screening.id,
      allegation_types: ['Exploitation']
    )
    screening.allegations << new_allegation

    expect(
      a_request(:put, api_screening_path(screening.id))
      .with(json_body(as_json_without_root_id(screening).merge('participants' => [])))
    ).to have_been_made
  end
end