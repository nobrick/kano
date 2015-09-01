class SessionsController < Devise::SessionsController
  # before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    super do
      # Also sign in the corresponding `User` or `Handyman` resource.
      sti_scope = resource.type.underscore
      sti_resource = resource.type.constantize.send(:find, resource.id)
      sign_in(sti_scope, sti_resource) unless resource.type.nil?
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # You can put the params you want to permit in the empty array.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end
