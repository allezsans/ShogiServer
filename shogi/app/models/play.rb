class Play < ActiveRecord::Base
  MAX_PLAYER_COUNT = 2
  has_many :user, :as => :turn_player
  has_many :user, :as => :first_player
  has_many :user, :as => :last_player
  has_many :user, :as => :winner
  validates :room_no, presence: true
  validates :state, presence: true

  def end?
    self.state == "finish" || self.state == "exit"
  end

  def end(id)
    self.state = "finish"
    save
  end

  def next_turn!
    self.turn_count = self.turn_count + 1

    if turn_player? self.first_player
      self.turn_player = self.last_player
    else
      self.turn_player = self.first_player
    end

    save!
  end

  def turn_player?(player)
    turn_player == player
  end

  def self.room_blank?(room_no)
    self.where(room_no: room_no).count.zero? || self.where(room_no: room_no).last.end?
  end

  def self.create_room(room_no:, user_id:)
    play = self.create(room_no: room_no)
    PlayingUser.create(play_id: play.id, user_id: user_id, role: 'player', exit_flag: false)
    play
  end

  def game_end!
    self.winner = self.turn_player
    self.state = "finish"
    self.save
    # 7. ルーム内全員を退出処理
    users = PlayingUser.where(play_id: self.id).all
    users.each do |user|
      user.exit_flag = true
      user.save!
    end
  end

  def join_user(user_id)
    role = 'watcher'
    if PlayingUser.where(play_id: id).count < MAX_PLAYER_COUNT
      self.state = 'playing'
      role = 'player'
      self.decide_order(user_id)
      self.save
      Piece.initialize_pieces(play_id: id, first_player_id: first_player, last_player_id: last_player)
    end
    PlayingUser.create(play_id: id, user_id: user_id, role: role, exit_flag: false)
  end

  def decide_order(user_id)
    other_user_id = PlayingUser.where(play_id: id).first.user_id
    players = [user_id, other_user_id].shuffle
    self.first_player, self.last_player = players[0], players[1]
    self.turn_player = self.first_player
  end

  def role_for_user(user_id)
    if waiting? || has_player?(user_id)
      'player'
    else
      'watcher'
    end
  end

  def has_player?(user_id)
    [first_player, last_player].include? user_id
  end

  def waiting?
    state == 'waiting'
  end

  def to_exit(user_id)
    self.state = 'exit'
    self.winner = self.first_player == user_id.to_i ? self.last_player : self.first_player
    self.save
    self.id
  end
end
