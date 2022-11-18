class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  include Pagy::Backend

  def route_not_found
    render partial: 'layouts/page_not_found'
  end
end
