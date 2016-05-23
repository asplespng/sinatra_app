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
require 'pony'

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
set :pony_defaults, {via: :smtp, via_options: { address: "localhost", port: 1025 }}

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
    @user = User.new
    haml :'users/new'
end

post '/users' do
    @user = User.new(email: params['email'].presence, password: params['password'].presence)
    if @user.save
      flash[:info] = "User sucessfully created"
      mail_options = {
          to: @user.email,
          from: "a@example.com",
          subject: "Please confirm your registration",
          body: "successfully registered",
          html_body: (haml :'mailers/test', layout: false)
      }
      Pony.mail(mail_options.merge settings.pony_defaults)
      redirect '/users'
    else
      haml :'users/new'
    end
end

get '/users/:id/edit' do |id|
  @user = User.find(id)
  haml :'users/edit'
end

get '/users/confirm' do
  @user = User.find_by_email params[:email]
  if @user.confirm_token == params[:token]
    @user.update(confirmed: true)
  end
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


delete '/users/:id' do
  @user = User.find(params[:id])
  @user.destroy!
  flash[:info] = "User sucessfully deleted"
  redirect :users
end
