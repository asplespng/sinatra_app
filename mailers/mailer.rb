require 'pony'
require 'tilt/haml'
class Mailer
  def initialize
    Pony.options = Sinatra::Application.settings.pony_defaults
  end

  def confirmation_mailer(options)
    @token = options[:token]
    subject = "Please confirm your registration"
    to = options[:to]
    tmpl = Tilt.new("#{Sinatra::Application.views}/mailers/confirm_registration.haml")
    html_body = (tmpl.render(self))

    Pony.mail(to: to, subject: subject, html_body: html_body)
  end

  def reset_password_mailer(options)
    @token = options[:token]
    subject = "Please reset your password"
    to = options[:to]
    tmpl = Tilt.new("#{Sinatra::Application.views}/mailers/reset_password.haml")
    html_body = (tmpl.render(self))
    Pony.mail(to: to, subject: subject, html_body: html_body)
  end
end