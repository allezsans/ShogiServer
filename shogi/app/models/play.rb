class Play < ActiveRecord::Base
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
    turn_count += 1
    if turn_player? first_player
      turn_player = last_player
    else
      turn_player = first_player
    end

    save!
  end

  def turn_player?(player)
    turn_player == player
  end
end
