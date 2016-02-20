class Handymen::ProfilesController < ProfilesController
  before_action :authenticate_completed_handyman, only: [ :show ]
  before_action :gray_background, only: [ :show ]

  def show
  end

  def update
    creates_pending_codes
    destroy_pending_codes
    pend_again_declined_codes
    super do |event|
      @account.taxons.reload if event == :failure
    end
  end

  private

  def after_update_success_path
    handyman_taxons_path
  end

  def selected_codes
    (params['taxon_codes'] || '').split(',').map(&:strip)
  end

  def creates_pending_codes
    codes = selected_codes - @account.taxon_codes
    @account.taxons.create(codes.map { |e| { code: e } })
  end

  def destroy_pending_codes
    codes = @account.taxon_codes(:pending) - selected_codes
    @account.taxons.pending.where(code: codes).destroy_all
  end

  def pend_again_declined_codes
    codes = @account.taxon_codes(:declined) & selected_codes
    @account.taxons.declined.where(code: codes).each do |taxon|
      taxon.pend && taxon.save!
    end
  end
end
