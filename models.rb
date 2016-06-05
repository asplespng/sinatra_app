class User < ActiveRecord::Base
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
    rescue
      # raise ActiveRecord::RecordInvalid.new(self)
    end
  end

  def send_confirm_email
    mail_options = {
        to: email,
        from: "a@example.com",
        subject: "Please confirm your registration",
        body: "successfully registered",
        html_body: (haml :'mailers/confirm_registration', layout: false)
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
