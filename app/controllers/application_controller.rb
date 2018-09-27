class ApplicationController < ActionController::Base
  before_action :confiture_permit_params, if: :devise_controller?

  protected

  def confiture_permit_params
    added_attrs = [ :username ]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
    devise_parameter_sanitizer.permit :sign_in, keys: added_attrs
  end
end
