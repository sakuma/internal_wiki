source 'https://rubygems.org'
ruby '2.1.1'

# gem 'rails', :git => 'git://github.com/rails/rails.git'
gem 'rails', '4.0.3'

gem 'pg'
# gem 'sqlite3'
# gem 'mysql2'

gem 'jquery-rails'
gem 'uglifier'
gem 'jquery-ui-rails'
# Using Node.js on server
# gem 'libv8'
# gem 'therubyracer'
gem 'bootstrap-sass-rails'
gem 'github-markup'
gem 'github-markdown'
gem 'gollum-lib'
gem 'sorcery'
gem 'active_decorator'
gem 'settingslogic'
gem 'private_pub' # WebSocket
gem 'thin' # for websocket server
gem 'puma' # web
gem 'tire' # for ElasticSearch
gem 'haml-rails'
gem 'sass-rails'
gem 'sprockets-rails', require: 'sprockets/railtie'
gem 'font-awesome-rails'
gem 'coffee-rails'
gem 'foreman'
gem 'paperclip'
gem 'aws-sdk'
gem 'angular-gem'
gem 'never_wastes'
gem 'gemoji'
gem 'rake'

group :production do
  gem 'aws-ses', require: 'aws/ses'
end

group :development do
  # gem 'debugger'
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-docmore'
  gem 'pry-byebug'
  # gem 'pry-nav' # pry-debugger があれば不要
  # gem 'pry-coolline' # 日本語入力語に文字化けしてしまうからコメントアウト
  gem 'pry-stack_explorer'
  gem 'pry-remote'
  gem 'pry-rescue'
  gem 'pry-coolline'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'hirb'
  gem 'hirb-unicode'
  gem 'coolline'
  gem 'awesome_print'
  gem 'i18n_generators'
  gem 'rails-footnotes'
  gem 'bullet'
  gem 'meta_request' # development log viewer for Chrome. via --- https://chrome.google.com/webstore/detail/railspanel/gjpfobpafnhjhbajcjgccbbdofdckggg
  gem 'rails-erd'
  gem 'letter_opener'
  gem 'guard'
  gem 'guard-livereload'  # Chrome Extention: https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei
end

group :development, :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'headless'
  gem 'launchy'
  gem 'factory_girl_rails', require: false
  gem 'faker', require: false
  gem 'guard-rspec'
  gem "spring-commands-rspec"
end

group :test do
  gem 'coveralls', require: false
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
  gem 'database_rewinder'
end
