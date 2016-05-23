class User < ActiveRecord::Base
  before_create :generate_confirm_token
  has_secure_password
  validates :email, presence: true, uniqueness: true, format: {with: /@/}

  def generate_confirm_token
    loop do
      self.confirm_token = SecureRandom.hex
      break unless User.find_by(confirm_token: confirm_token)
    end
  end
end
