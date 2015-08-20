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

  def self.update!(params)
    self.check_update_parameter!(params)

    Piece.transaction do
      self.move_piece!(play_id: params[:play_id], piece_id: params[:move_id], posx: params[:posx], posy: params[:posy], promote: params[:promote])

      if params[:get_id].in? ('1'..'40').to_a
        self.got_piece!(play_id: params[:play_id], piece_id: params[:get_id], user_id: params[:user_id])
      end

      Play.transaction do
        Play.find(params[:play_id]).next_turn!
      end
    end
  end

  private

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

  def self.check_update_parameter!(params)
    binding.pry
    raise 'Invalid Parameter' unless self.piece_id_valid? params[:move_id]
    raise 'Invalid Parameter' unless self.piece_id_valid? params[:get_id]
    raise 'Invalid Parameter' if self.find(params[:move_id]).onwer? params[:user_id]
    raise 'Invalid Parameter' unless self.find(params[:get_id]).onwer? params[:user_id]
    raise 'Invalid Parameter' unless self.position_valid? params[:pos_x]
    raise 'Invalid Parameter' unless self.position_valid? params[:pos_y]
    raise 'Invalid Parameter' unless Play.find(params[:play_id]).has_player? params[:user_id]
    raise 'Invalid Parameter' unless self.got_id_valid?(params[:get_id])
  end

  def self.got_id_valid?(piece_id)
    if piece_id == '-1'
      true
    elsif piece_id.in? ('1'..'40').to_a
      Play.find(params[:play_id]).has_player? self.find(params[:get_id]).owner
    else
      false
    end
  end

  def self.piece_id_valid?(piece_id)
    self.find(piece_id).piece_id.in? (1..40).to_a
  end

  def self.position_valid?(position)
    position.in? ('1'..'9').to_a
  end

  def owner?(user_id)
    self.owner == user_id
  end
end
