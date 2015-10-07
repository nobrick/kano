require 'rails_helper'

RSpec.describe Handymen::OrderContractsController, type: :controller do
  before { sign_in :handyman, handyman }
  let(:user) { create :user }
  let(:handyman) { create :handyman }

  # TODO
end
