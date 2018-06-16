class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper
  include SessionsHelper

  before_action :get_base_url

  around_action :global_request_logging

  def global_request_logging
    logger.info "USERAGENT: #{request.headers['HTTP_USER_AGENT']}"
    begin
      yield
    ensure
      #logger.info "response_status: #{response.status}"
    end
  end

  # for responding SUCCESS to AJAX actions
  def ok_JSON_response
    render json: { success: "success", status_code: "200" }
  end

  def fail_JSON_response
    render status: 500, json: { status_code: "500" }
  end

  def fail_JSON_message(message)
    render status: 500, json: { status_code: "500", message: message }
  end
end
