class ApplicationController < RappedApplicationController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, if: :json_request?

  # Make sure we ask CanCan about permissions in every controller action.
  check_authorization


  private

    def json_request?
      request.format.json?
    end



end
