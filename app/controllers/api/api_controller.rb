class Api::ApiController < ApplicationController
  before_action :authenticate_api_user!
end