class Handymen::ProfilesController < ProfilesController
  private

  def profile_params
    parameters = params.require(:profile).permit(
      :email,
      :phone,
      :name,
      :nickname,
      primary_address_attributes: [ :code, :content ],
      taxons_attributes: [ :code ]
    )
  end
end
