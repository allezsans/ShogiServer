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
    piece.promote = (promote.downcase == 'true') ? true : false
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

    Play.find(play_id).game_end! if piece_id.in? ['39', '40']
  end

  def self.initialize_pieces(play_id:, first_player_id:, last_player_id:)
    (1..40).to_a.each do |id|
      master = MasterPiece.find(id)
      owner_id = master.owner == 1 ? first_player_id : last_player_id
      self.create(
        # data[:owner]が1なら先手、2なら後手の駒。
        :piece_id => master.id, :play_id => play_id, :posx => master.posx, :posy => master.posy, :promote => false, :owner => owner_id
      )
    end
  end
end
