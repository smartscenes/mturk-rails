class IdentitiesController < ApplicationController
  def new
    @identity = ENV['omniauth.identity']
  end
end
