class User < ActiveRecord::Base
  before_create -> { self.confirm_token = SecureRandom.hex }
  has_secure_password
  validates :email, presence: true, uniqueness: true, format: {with: /@/}
end
