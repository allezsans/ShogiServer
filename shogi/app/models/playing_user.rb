class PlayingUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :play

  scope :play_is, lambda { |play_id|where(:play_id => play_id) }
  scope :other_player_is, lambda{ |play_id|where(:play_id => play_id, :role => 'player').first }

  def self.logout(user_id:, play_id:)
    user = self.where(user_id: user_id, play_id: play_id).first
    user.exit_flag = true
    user.save

    if user.role == 'player'
      Play.find(play_id).to_exit(user_id: user_id)
      self.exit_users(user_id: user_id, play_id: play_id)
    end
  end

  def self.exit_users(play_id:, user_id:)
    PlayingUser.where(user_id: user_id, play_id: play_id).each do |user|
      user.exit_flag = true
      user.save
    end
  end
end
