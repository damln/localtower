<p align="center">
<img src="https://raw.githubusercontent.com/damln/localtower/master/public/logo-localtower-white-300.png" alt="Localtower">
</p>

## Intro

Update in 2022, please use localtower version `>= 0.4.1`
See installation process below.
Compatibility:
- Rails >= 5.2
- Ruby >= 2.3

### See the schema
![Schema](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v0.1.6/1_schema.png)

### Create a model
![Models](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v0.1.6/2_models_1.png)

### Create a many to many relation
![Relations](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v0.1.6/3_relations.png)

### Create a migration
![Migrations](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v0.1.6/4_migrations.png)

## INSTALL

Should work with any Rails 4.2+ application.
Only tested with PostgreSQL.

Add to your `Gemfile` file:
```ruby
group :development do
  gem "localtower"
end
```

Run command in your terminal:
```bash
bundle install
```

Add to your `config/routes.rb`:
```ruby
MyApp::Application.routes.draw do
  if Rails.env.development? and defined?(Localtower)
    mount Localtower::Engine, at: "localtower"
  end

  # Your other routes here:
  # ...
end
```

/!\ IMPORTANT /!\
Change your config/environments/development.rb:

```ruby
Rails.application.configure do
  # ...

  # This is the default:
  # config.active_record.migration_error = :page_load

  # Change it to:
  config.active_record.migration_error = false if defined?(Localtower)

  # ...
end
```

## Usage

Open your browser at [http://localhost:3000/localtower](http://localhost:3000/localtower).


## Run test

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

## Contribute

Thanks for reporting issues, I'll do my best 💪

![ga](https://www.google-analytics.com/collect?v=1&tid=G-1XG3EBE2DZ&cid=555&aip=1&t=event&ec=github&ea=visit&dp=readme&dt=gem)


## Deploy
Only for official contributors.

    rm *.gem | gem build localtower.gemspec && gem push localtower-*.gem

## Notes

Do not hesitate to open issues if you have troubles using the gem.

- By Damian Le Nouaille Diez: https://damln.com
- Link on RubyGems: https://rubygems.org/gems/localtower
