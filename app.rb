require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/activerecord'
require 'sprockets'
require 'uglifier'
require 'sass'
require 'coffee-script'
require './models'
require 'sinatra/flash'
require_relative 'lib/authentication'

helpers Authentication
helpers do
  def redirect_to_original_request
    user_id = session[:user_id]
    flash[:info] = "Welcome back #{User.find(user_id).email}."
    original_request = session[:original_request]
    session[:original_request] = nil
    redirect original_request
  end
  def current_user
    @current_user ||= session[:user_id].present? ? User.find(session[:user_id]) : nil
  end
end

enable :sessions

set :database, "sqlite3:sinatra_app_dev.sqlite3"
# initialize new sprockets environment
set :sprockets, Sprockets::Environment.new
#
# # append assets paths
settings.sprockets.append_path "assets/stylesheets"
settings.sprockets.append_path "assets/javascripts"
settings.sprockets.append_path "assets/fonts"

configure :production do
  # compress assets
  settings.sprockets.js_compressor  = :uglify
  settings.sprockets.css_compressor = :scss
end

# get assets
get "/assets/*" do
  env["PATH_INFO"].sub!("/assets", "")
  settings.sprockets.call(env)
end

get '/' do
  "Welcome"
end

enable :sessions
helpers do
  def logged_in?
    session['user_id'].present?
  end

end
get '/users' do
  @users = User.all
  haml :'users/index'
end

get '/users/new' do
    haml :'users/new'
end

post '/users' do
    @user = User.new(email: params['email'].presence, password: params['password'].presence)
    if @user.save
      flash[:info] = "User sucessfully created"
      redirect '/users'
    else
      haml :'users/new'
    end
end

get '/users/:id/edit' do |id|
  @user = User.find(id)
  haml :'users/edit'
end

put '/users/:id' do
  @user = User.find(params[:id])
  @user.update!(email: params[:email])
  flash[:info] = "User sucessfully updated"
  redirect '/users'
end

get '/sessions/new' do
  haml :'/sessions/new'
end

post '/sessions' do
  user = User.find_by(email: params[:email])
  if user && user.authenticate(params[:password])
    session[:user_id] = user.id
    redirect_to_original_request
  else
    flash[:danger] = "Email or password incorrect."
    redirect '/sessions/new'
  end
end

get '/sessions/success' do
  authenticate!
  haml :'/sessions/success'
end

get '/sessions/sign_out' do
  session.clear
  redirect :'/sessions/new'
end

get '/users/:id/delete' do
  @user = User.find(params[:id])
  haml :'/users/delete'
end


delete '/users/:id' do
  @user = User.find(params[:id])
  @user.destroy!
  flash[:info] = "User sucessfully deleted"
  redirect :users
end
