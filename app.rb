require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/activerecord'
require 'sprockets'
require 'uglifier'
require 'sass'
require 'coffee-script'
require './models'
require 'sinatra/flash'

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

get '/hello/:name' do
  name = params[:name]
  "Hello #{name}"
end

get '/users' do
  @users = User.all
  haml :'users/index'
end

get '/users/new' do
    haml :'users/new'
end

post '/users' do
    email = params[:email]
    User.create(email: email)
    flash[:info] = "User sucessfully created"
    redirect :users
end

get '/users/:id/edit' do
  @user = User.find(params[:id])
  haml :'users/edit'
end

put '/users/:id' do
  @user = User.find(params[:id])
  @user.update!(email: params[:email])
  flash[:info] = "User sucessfully updated"
  redirect :users
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
