require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/activerecord'
require 'sprockets'
require 'uglifier'
require 'sass'
require 'coffee-script'
require './models'
require 'sinatra/flash'
require_relative 'lib/sinatra/authentication'
require_relative 'lib/partials'
require 'pony'
require_relative 'config/environments'
require 'omniauth'
require 'omniauth-twitter'
require 'omniauth-pinterest'
require 'omniauth-facebook'
require 'omniauth-google-oauth2'

helpers do

end


enable :sessions

use OmniAuth::Builder do
  provider :twitter, ENV['TWITTER_OMNIAUTH'], ENV['TWITTER_OMNIAUTH_SECRET']
  provider :pinterest, ENV['PINTEREST_OMNIAUTH'], ENV['PINTEREST_OMNIAUTH_SECRET']
  provider :facebook, ENV['FACEBOOK_OMNIAUTH'], ENV['FACEBOOK_OMNIAUTH_SECRET']
  provider :google_oauth2, ENV['GOOGLE_OMNIAUTH'], ENV['GOOGLE_OMNIAUTH_SECRET']
end

# set :database, "sqlite3:sinatra_app_dev.sqlite3"

# initialize new sprockets environment
set :sprockets, Sprockets::Environment.new
#
# # append assets paths
settings.sprockets.append_path "assets/stylesheets"
settings.sprockets.append_path "assets/javascripts"
settings.sprockets.append_path "assets/fonts"

# see http://ruslanledesma.com/2016/04/23/release-connections-thin-and-active-record.html
after do
  ActiveRecord::Base.clear_active_connections!
end

# get assets
get "/assets/*" do
  env["PATH_INFO"].sub!("/assets", "")
  settings.sprockets.call(env)
end

get "/fonts/*" do
  env["PATH_INFO"].sub!("/fonts", "")
  settings.sprockets.call(env)
end

get '/auth/*/callback' do
  auth = env['omniauth.auth']
  user = User.where( uid: auth['uid'], auth_provider: auth['provider']).first_or_initialize
  name = nil
  if auth['info']['name'].present?
    name = auth['info']['name']
  else
    if auth['info']['first_name'].present?
      name = auth['info']['first_name']
      name += " #{auth['info']['last_name']}" if auth['info']['last_name'].present?
    end
  end
  user.attributes = {uid: auth['uid'], name: name, auth_provider: auth['provider']}
  user.save!
  session[:user_id] = user.id
  redirect_to_original_request
end

get '/auth/failure' do
  flash_message = "Authentication failed."
  flash_message += " Message was: #{params[:message]}" if params[:message].present?
  flash[:danger] = flash_message
  redirect '/sessions/new'
end

get '/' do
  authenticate!
  haml :'index'
end

enable :sessions
helpers do
  def logged_in?
    session['user_id'].present?
  end

end
get '/users' do
  authenticate!
  @users = User.all
  haml :'users/index'
end

get '/users/new' do
    @user = User.new
    haml :'users/new'
end

post '/users' do
    @user = User.new(name: params['name'].presence, email: params['email'].presence, password: params['password'].presence)
    if @user.save
      flash[:info] = "User sucessfully created"
      redirect '/users'
    else
      flash.now[:danger] = "There was a problem with your registration"
      haml :'users/new'
    end
end

get '/users/:id/edit' do |id|
  @user = User.find(id)
  haml :'users/edit'
end

get '/users/confirm/:token' do
  @user = User.find_by_confirm_token params[:token]
  if @user
    @user.update(confirmed: true)
    flash[:info] = "Your account has been confirmed"
    redirect "/sessions/new?email=#{@user.email}"
  end
end

put '/users/:id' do
  @user = User.find(params[:id])
  values = {email: params[:email], name: params[:name]}
  values.merge!(password: params[:password]) if params[:password].present?
  @user.update!(values)
  flash[:info] = "User sucessfully updated"
  redirect '/users'
end

get '/sessions/new' do
  @email = params[:email]
  flash[:danger] = "You are already signed in" if current_user
  haml :'/sessions/new'
end

post '/sessions' do
  user = User.find_by(email: params[:email])
  if user && user.authenticate(params[:password])
    if user.confirmed?
      session[:user_id] = user.id
      redirect_to_original_request
    else
      flash[:danger] = "Account not confirmed"
      redirect '/sessions/new'
    end
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

get '/users/reset_password' do
  @user = User.new
  haml :'/users/reset_password'
end

post '/users/reset_password' do
  @user = User.new(email: params[:email], skip_email_uniqueness: true)
  @user.validate
  if @user.errors[:email].any?
    flash.now[:danger] = "There was a problem"
  else
    @user = User.find_by_email(params[:email])
    if @user.present?
      if @user.send_password_reset_token
        flash.now[:info] = "We have sent you an email with further instructions"
      else
        flash.now[:danger] = "There was a problem"
      end
    else
      @user = User.new
      flash.now[:danger] = "There was a problem"
      @user.errors.add(:email, "A user with that email could not be found")
    end
  end
  @user
  haml :'/users/reset_password'
end

get '/users/reset_password/:token' do
  @user = User.find_by(password_reset_token: params[:token])
  flash.now[:danger] = "User not found" if @user.blank?
  haml :'/users/new_password'
end

post '/users/reset_password/:token' do
  @user = User.find_by(password_reset_token: params[:token])
  if @user.present?
    @user.password = params[:password]
    if @user.save
      flash[:info] = "Password updated"
      redirect "/sessions/new?email=#{@user.email}"
    else
      flash.now[:danger] = "There was a problem"
    end
  else
    flash.now[:danger] = "User not found"
  end
  haml :'/users/new_password'
end

delete '/users/:id' do
  @user = User.find(params[:id])
  @user.destroy!
  flash[:info] = "User sucessfully deleted"
  redirect :users
end
