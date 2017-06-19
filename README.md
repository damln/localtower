<p align="center">
<img src="https://raw.githubusercontent.com/damln/localtower/master/public/logo-localtower-white-300.png" alt="Localtower">
</p>

### See the schema
![Schema](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v0.1.6/1_schema.png)

### Create a model
![Models](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v0.1.6/2_models_1.png)

### Create a many to many relation
![Relations](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v0.1.6/3_relations.png)

### Create a migration
![Migrations](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v0.1.6/4_migrations.png)


## INSTALL

Only tested with Rails 4.2 and Rails 5.1 (should work with any Rails 4.2+ application).
Only tested with PostgreSQL.

Add to your `Gemfile` file:
```ruby
group :development do
  gem "localtower"
end
```

If you want the latest master branch, add to your `Gemfile` file following:
```ruby
group :development do
  gem "localtower", github: "damln/localtower"
end
```

Run command in your terminal:
```bash
bundle install
```

Add to your `config/routes.rb`:
```ruby
MyApp::Application.routes.draw do
  if Rails.env.development?
    mount Localtower::Engine, at: "localtower"
  end
  
  # Your other routes here:
  # ...
end

```

## Usage

Open your browser at [http://localhost:3000/localtower](http://localhost:3000/localtower).

## RSpec and Contribute

If you want to contribute to the gem:

Create a `spec/dummy/.env` file with the credentials to your PostgreSQL Database. It should look like this:

```
LOCALTOWER_PG_USERNAME="admin"
LOCALTOWER_PG_PASSWORD="root_or_smething"
```

Run the spec:
```bash
bundle install
bundle exec rspec spec/
```

Notes:
Tests are currently very slow because this is testing rails commands so it boots the framework for each test. Zeus or spring should be introduced.

## Contribute

Thanks for reporting issues, I'll do my best.

[![Analytics](https://ga-beacon.appspot.com/UA-93841935-1/github-readme?pixel)](https://github.com/damln/localtower)
