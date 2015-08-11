class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # POST /users/login
  def login
    @user = User.create!(name: params[:name])

    if Play.room_blank?(params[:room_no])
      @play = Play.create_room(room_no: params[:room_no], user_id: @user.id)
    else
      @play = Play.where(:room_no => params[:room_no]).last
      @play.join_user(@user.id)
    end

    @role = @play.role_for_user(@user.id)

    render "login", :formats => [:json], :handlers => [:jbuilder]
  end

  def logout
    PlayingUser.logout(user_id: params[:user_id], play_id: params[:play_id])
    render :json => ['true']
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:name)
  end
end
