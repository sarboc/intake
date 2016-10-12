# frozen_string_literal: true

# Screening Controller handles all service request for
# the creation and modification of screening objects.
class ScreeningsController < ApplicationController # :nodoc:
  PERMITTED_PARAMS = [
    :ended_at,
    :incident_county,
    :incident_date,
    :location_type,
    :method_of_referral,
    :name,
    :narrative,
    :reference,
    :response_time,
    :screening_decision,
    :started_at,
    address: [
      :id,
      :city,
      :state,
      :street_address,
      :zip
    ],
    involved_person_ids: []
  ].freeze

  def create
    @screening = Screening.create(reference: LUID.generate.first)
    redirect_to edit_screening_path(@screening)
  end

  def update
    @screening = Screening.save_existing(
      params[:id],
      screening_params.to_h
    )
    redirect_to screening_path(@screening)
  end

  def edit
    @screening = Screening.find(params[:id])
    @involved_people = @screening.involved_people.to_a
  end

  def show
    @screening = Screening.find(params[:id])
    @involved_people = @screening.involved_people.to_a
  end

  def index
    respond_to do |format|
      format.html
      format.json do
        screenings = ScreeningsRepo.search(query).results
        render json: screenings
      end
    end
  end

  private

  def query
    { query: { filtered: { filter: { bool: { must: search_terms } } } } }
  end

  def search_terms
    terms = []

    terms << { terms: { response_time: response_times } } if response_times
    terms << { terms: { screening_decision: screening_decisions } } if screening_decisions

    terms
  end

  def response_times
    params[:response_times]
  end

  def screening_decisions
    params[:screening_decisions]
  end

  def screening_params
    params.require(:screening).permit(*PERMITTED_PARAMS)
  end
end