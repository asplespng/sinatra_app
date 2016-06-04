class User < ActiveRecord::Base
  before_create :generate_confirm_token
  has_secure_password(validations: false)
  validates_presence_of :password, on: :create, unless: :uid
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: {with: /@/}, unless: :uid

  def generate_confirm_token
    loop do
      self.confirm_token = SecureRandom.hex
      break unless User.find_by(confirm_token: confirm_token)
    end
    begin
      send_confirm_email
    rescue
      # handle error
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
end
