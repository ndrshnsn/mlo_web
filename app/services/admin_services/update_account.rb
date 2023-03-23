class AdminServices::UpdateAccount < ApplicationService
  def initialize(user, params)
    @user = user
    @params = params
    @active = true
  end

  def call
    ActiveRecord::Base.transaction do
      update_account
    end
  end

  private

  def update_account
    @active = false if @params[:status] == 'inactive'
    return OpenStruct.new(success?: false, user: nil, errors: @user.errors) unless @user.update!(
      role: @params[:role].to_i,
      active: 123
      )
    OpenStruct.new(success?: true, user: @user, errors: nil)
  end
end