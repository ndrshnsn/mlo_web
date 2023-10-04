class AppServices::Trades::Buy < ApplicationService
  def initialize(params=nil)
    @params = params
    @user = @params[:user] if @params
  end

  def call
    ActiveRecord::Base.transaction do
      update_acl
    end
  end


  private


end
