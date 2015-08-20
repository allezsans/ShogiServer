class PlaysController < ApplicationController
  before_action :set_play, only: [:state, :users, :get_winner, :show, :get_pieces]

  def state
    render "state", :formats => [:json], :handlers => [:jbuilder]
  end

  def users
    render "users", :formats => [:json], :handlers => [:jbuilder]
  end

  def show
    # 現在のターン数、観客の人数、状態を返す
    @watcher_count = PlayingUser.where( :play => @play, :role => 'watcher' ).count
    render "show", :formats => [:json], :handlers => [:jbuilder]
  end

  def get_winner
    render "winner", :formats => [:json], :handlers => [:jbuilder]
  end

  def get_pieces
    @pieces = Piece.where(:play => @play.id).all
    # binding.pry
    render "pieces", :formats => [:json], :hanlders => [:jbuilder]
  end

  # 駒情報の更新
  def update
    Piece.update!(update_piece_params)
    @update = true
    render "update", :formats => [:json], :hanlders => [:jbuilder]
  # rescue
  #   @update = false
  #   render "update", :formats => [:json], :hanlders => [:jbuilder]
  end

  # debug用
  def end
    @play = Play.find(params[:id])
    render 'state', :formats => [:json], :hanlders => [:jbuilder]
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_play
    begin
      @play = Play.find(params[:id])
    rescue
      @error = "record not found"
      render "users/error", :formats => [:json], :handlers => [:jbuilder] and return
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def play_params
    params.require(:play).permit(:turn_player, :turn_number, :end_flag, :room_no)
  end

  def update_piece_params
    {
      play_id: params[:play_id],
      move_id: params[:move_id],
      get_id: params[:get_id],
      posx: params[:posx],
      posy: params[:posy],
      promote: params[:promote],
      user_id: params[:user_id]
    }
  end
end
