require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/activerecord'

set :database, "sqlite3:sinatra_app_dev.sqlite3"

require './models'

get '/hello/:name' do
  name = params[:name]
  "Hello #{name}"
end

# get '/:name' do
#   name = params[:name]
#   "Hello #{name}"
# end

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
    redirect :users
end

get '/users/:id/edit' do
  @user = User.find(params[:id])
  haml :'users/edit'
end

put '/users/:id' do
  @user = User.find(params[:id])
  @user.update!(email: params[:email])
  redirect :users
end

delete '/users/:id' do
  @user = User.find(params[:id])
  @user.destroy!
  redirect :users
end
