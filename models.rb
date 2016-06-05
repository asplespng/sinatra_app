class User < ActiveRecord::Base
  require 'tilt/haml'

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
    tmpl = Tilt.new("#{Sinatra::Application.views}/mailers/confirm_registration.haml")

    mail_options = {
        to: email,
        from: "a@example.com",
        subject: "Please confirm your registration",
        body: "successfully registered",
        html_body: (tmpl.render(self))
    }
    Pony.mail(Sinatra::Application.settings.pony_defaults.merge mail_options)
  end

  def has_credentials?
    email.present? && password.present?
  end

  def has_omni_auth?
    uid.present?
  end
end
