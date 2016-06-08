class User < ActiveRecord::Base
  require 'tilt/haml'
  require_relative 'mailers/mailer'

  before_create :generate_confirm_token, if: :has_credentials?
  has_secure_password(validations: false)
  validates :password, :email, presence: true, unless: :has_omni_auth?
  validates :name, presence: true
  validates :email, format: {with: /@/}
  validates :email, uniqueness: true, unless: :skip_email_uniqueness

  attr_accessor :skip_email_uniqueness

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
    mailer.confirmation_mailer(to: "#{name} <#{email}>", token: confirm_token)
  end

  def send_password_reset_token
    loop do
      self.password_reset_token = SecureRandom.hex
      break unless User.find_by(password_reset_token: confirm_token)
    end
    begin
      mailer = Mailer.new
      mailer.reset_password_mailer(to: "#{name} <#{email}>", token: password_reset_token)
    rescue => e
      # todo log exception
      errors.add(:email, "There was an error sending password_reset email. Please try again.")
      return false
    end
    self.save
    true
  end

  def has_credentials?
    email.present? && password.present?
  end

  def has_omni_auth?
    uid.present?
  end
end
