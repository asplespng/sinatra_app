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
      flash[:info] = "Welcome #{current_user.name}."
      original_request = session[:original_request]
      session[:original_request] = nil
      redirect original_request
    end

    def current_user
      @current_user ||= session[:user_id].present? ? User.find_by(id: session[:user_id]) : nil
    end
  end

  helpers Authentication
end
