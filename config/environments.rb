configure :development do
  db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/sinatra_app_development')

  ActiveRecord::Base.establish_connection(
      adapter: db.scheme == 'postgres' ? 'postgresql' : db.scheme,
      host: db.host,
      username: db.user,
      password: db.password,
      database: db.path[1..-1],
      encoding: 'utf8'
  )
  set :pony_defaults, {via: :smtp, via_options: { address: "localhost", port: 1025 }}
end
configure :production do
  db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/sinatra_app_production')

  ActiveRecord::Base.establish_connection(
      adapter: db.scheme == 'postgres' ? 'postgresql' : db.scheme,
      host: db.host,
      username: db.user,
      password: db.password,
      database: db.path[1..-1],
      encoding: 'utf8'
  )
# compress assets
  settings.sprockets.js_compressor  = :uglify
  settings.sprockets.css_compressor = :scss
end
