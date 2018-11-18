source 'http://rubygems.org'

gem 'rails', '5.1.6'
gem 'rake', '12.3.0'
gem 'bootstrap-sass', '~> 3.3.7'
gem 'bcrypt', '~> 3.1.11'
gem 'faker', '1.8.7'
gem 'activemodel', '~> 5.1.4'
gem 'activeresource', '~> 5.0.0'

# Use Puma as the app server
gem 'puma', '~> 3.7'

# For admin interface
gem 'activeadmin', '1.0.0' #github: 'activeadmin'
# For activeadmin authentication
gem 'devise'

# For batch import
gem 'activerecord-import', '~> 0.22.0'

# For authenticating with twitter/google
gem 'omniauth-twitter', '1.4.0'
gem 'omniauth-google-oauth2', '0.5.3'
gem 'omniauth-identity', '1.1.1'

# For pagination
gem 'kaminari'
gem 'bootstrap-kaminari-views'

# For bootstrap styling of file input
gem 'bootstrap-filestyle-rails'

# For mechanical turk
gem 'rturk', '2.12.1'

# For uploading images
gem 'dragonfly', '~> 1.2.0'
# Caching
#gem 'rack-cache', :require  => 'rack/cache'

# For integration with solr
#gem 'sunspot_rails'

group :development, :test, :production do
  gem 'paper_trail' #'~> 2'
  gem 'sqlite3' #'1.3.5'
end

group :production do
  gem 'mysql2', '~> 0.5.1'
end

group :development, :test do
  gem "rack-reverse-proxy", :require => "rack/reverse_proxy"
  gem 'rspec-rails', '~> 3.7.2'
end

group :development do
  gem 'annotate', '2.7.3'
end

#group :development, :test do
#  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
#  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
#  # Adds support for Capybara system testing and selenium driver
#  gem 'capybara', '~> 2.13'
#  gem 'selenium-webdriver'
#end

#group :development do
#  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
#  gem 'web-console', '>= 3.3.0'
#  gem 'listen', '>= 3.0.5', '< 3.2'
#  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
#  gem 'spring'
#  gem 'spring-watcher-listen', '~> 2.0.0'
#end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails' #'~> 5.0'
  gem 'coffee-rails' #'~> 4.2'

  gem 'uglifier', '4.1.10'
end

gem 'jquery-rails', '~> 4.3.1'
gem 'sprockets-rails', '2.3.3'
gem 'requirejs-rails', git: 'https://github.com/MediaFactual/requirejs-rails.git', branch: 'rails5-1-0-0'
gem 'font-awesome-sass-rails' #'3.0.2.2'

# Switched to protected_attributes_continued for rails 5
# https://github.com/westonganger/protected_attributes_continued
# Switch to use strong_parameters
gem 'protected_attributes_continued'

# Not sure what this is used for - but added for Rails 5
gem 'erubis', '~> 2.7.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

# For dumping database to YAML files
gem 'yaml_db'

# For timezone info on windows
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

