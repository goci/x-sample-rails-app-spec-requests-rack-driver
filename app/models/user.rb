# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string(255)
#  remember_token  :string(255)
#  admin           :boolean          default(FALSE)
#

class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation
  has_many :microposts, dependent: :destroy
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :reverse_relationships,
           class_name: Relationship,
           foreign_key: "followed_id",
           dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :follower
  has_secure_password
  before_save do
    self.email.downcase!
    self.remember_token = SecureRandom.urlsafe_base64
  end
  
  validates :name, presence: true
  validates :email,
            presence: true,
            format: { with: %r{\w+@\w+} },
            uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }
  validates :password_confirmation, presence: true
  
  def feed
    Micropost.from_users_followed_by(self)
  end
  
  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end
  
  def unfollow!(other_user)
    following?(other_user).destroy
  end
  
  def following?(other_user)
    relationships.find_by_followed_id(other_user.id)
  end
end
