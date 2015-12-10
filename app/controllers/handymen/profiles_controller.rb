class Handymen::ProfilesController < ProfilesController
  before_action :authenticate_completed_handyman, only: [ :show, :edit ]

  def show
    @orders = Order.where(handyman: current_handyman)
      .order(updated_at: :desc).limit(2)
  end

  def update
    selected_codes = (params['taxon_codes'] || '').split(',')
    codes_to_create = selected_codes - @account.taxon_codes
    codes_to_destroy = @account.taxon_codes - selected_codes
    @account.taxons.where(code: codes_to_destroy).destroy_all
    @account.taxons.create(codes_to_create.map { |e| { code: e } })
    super do |event|
      @account.taxons.reload if event == :failure
    end
  end
end
