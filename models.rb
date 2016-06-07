class User < ActiveRecord::Base
  require 'tilt/haml'
  require_relative 'mailers/mailer'

  before_create :generate_confirm_token, if: :has_credentials?
  has_secure_password(validations: false)
  validates :password, :email, presence: true, on: :create, unless: :has_omni_auth?
  validates :name, presence: true
  validates :email, uniqueness: true, format: {with: /@/}

  def generate_confirm_token
    loop do
      self.confirm_token = SecureRandom.hex
      break unless User.find_by(confirm_token: confirm_token)
    end
    begin
      send_confirm_email
    rescue => e
      # todo log exception
      errors.add(:email, "There was an error sending confirmation email. Please try again.")
      raise ActiveRecord::RecordInvalid.new(self)
    end
  end

  def send_confirm_email
    mailer = Mailer.new
    mailer.confirmation_mailer(to: email, token: confirm_token)
  end

  def has_credentials?
    email.present? && password.present?
  end

  def has_omni_auth?
    uid.present?
  end
end
