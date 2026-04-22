class ApplicationController < ActionController::Base
  include ActiveStorage::SetCurrent

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: [:username, :address, :city, :province_id, :postal_code]
    )

    devise_parameter_sanitizer.permit(
      :account_update,
      keys: [:username, :address, :city, :province_id, :postal_code]
    )
  end
end
