module Authentication
  def authenticate!
    unless session[:user_id]
      session[:original_request] = request.path_info
      redirect '/sessions/new'
    end
  end
end