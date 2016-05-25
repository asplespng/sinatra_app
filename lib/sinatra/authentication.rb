require 'sinatra/base'
module Sinatra
  module Authentication
    def authenticate!
      unless session[:user_id]
        session[:original_request] = request.path_info
        redirect '/sessions/new'
      end
    end
    def redirect_to_original_request
      user_id = session[:user_id]
      flash[:info] = "Welcome back #{User.find(user_id).email}."
      original_request = session[:original_request]
      session[:original_request] = nil
      redirect original_request
    end
  end

  helpers Authentication
end
