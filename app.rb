require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/activerecord'
require 'bcrypt'

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
    user = User.new(email: params['email'], password: params['password'])
    if user.save
      redirect '/users'
    else
      redirect '/users/new'
    end
end

get '/users/:id/edit' do |id|
  @user = User.find(id)
  haml :'users/edit'
end

put '/users/:id' do
  @user = User.find(params[:id])
  @user.update!(email: params[:email])
  redirect '/users'
end

get '/sessions/new' do
  haml :'/sessions/new'
end

post '/sessions' do
  user = User.find_by(email: params[:email])
  if user && user.authenticate(params[:password])
    redirect '/sessions/success'
  else
    redirect '/sessions/new'
  end
end

get '/sessions/success' do
  haml :'/sessions/success'
end
