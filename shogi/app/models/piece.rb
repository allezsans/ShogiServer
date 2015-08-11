class Piece < ActiveRecord::Base
  belongs_to :master_piece, :foreign_key => :piece_id
  belongs_to :play
  belongs_to :user, :foreign_key => :owner

  validate :owner, :presence => true
  validate :posx, :presence => true
  validate :posy, :presence => true
  validate :piece_id, :presence => true
  validate :play_id, :presence => true
  validate :promote, :presence => true

  def name
    master_piece.name
  end

  def self.move_piece!(play_id:, piece_id:, posx:, posy:, promote:)
    # 1. play_idとuser_idとmove_idでpiecesテーブルからデータを拾ってくる
    piece = where(play_id: play_id, piece_id: piece_id).first
    # 2. posxとposyを更新
    piece.posx = posx
    piece.posy = posy
    # 3. 昇格したかどうかを値によって変更
    piece.promote = (promote == 'True') ? true : false
    piece.save!
  end

  def self.got_piece!(play_id:, piece_id:, user_id:)
    piece = Piece.where(play_id: play_id, piece_id: piece_id).first
    # 5. posxとposyを更新して保存
    piece.posx = 0
    piece.posy = 0
    piece.promote = false
    piece.owner = user_id
    piece.save!

    self.game_end!(play_id) if params[:get_id].in? ['39', '40']
  end

  def self.game_end!(play_id:)
    play = Play.find(play_id)
    @play.winner = @play.turn_player
    @play.state = "finish"
    # 7. ルーム内全員を退出処理
    @users = PlayingUser.where( :play_id => params[:play_id] ).all
    @users.each do |user|
      user.exit_flag = true
      user.save!
    end
  end
end
