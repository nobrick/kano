class Handymen::TaxonsController < ApplicationController
  # GET /taxons
  def index
    @handyman = current_handyman
    @taxons = @handyman.taxons
  end
end
