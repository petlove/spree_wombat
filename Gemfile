source 'https://rubygems.org'

gem 'spree', github: 'petlove/spree', branch: "custom-2.3"

gem 'coffee-rails', '~> 4.0.0'
gem 'sass-rails', '~> 4.0.0'

gem 'mysql2'
gem 'pg'

gem 'therubyracer'

group :test do
  gem 'hub_samples', github: "petlove/hub_samples", branch: "master"

  platforms :ruby_19 do
    gem 'pry-debugger'
  end
  platforms :ruby_20, :ruby_21 do
    gem 'pry-byebug'
  end
end

gemspec
