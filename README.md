<p align="center">
<img src="https://raw.githubusercontent.com/damln/localtower/master/public/logo-localtower-white-300.png" alt="Localtower">
</p>

## Intro

Please use localtower version `>= 1.0.0`
See installation process below.

Compatibility:
- Rails >= 5.2
- Ruby >= 2.3

### Create a model
![New Model](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v1.0.0/new_model.png)

### Create a migration
![New Migration](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v1.0.0/new_migration.png)

### See the Models
![Models](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v1.0.0/models.png)

### See the Migrations (and migrate)
![Migrations](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v1.0.0/migrations.png)

## INSTALL

Should work with any Rails 5.2+ application.
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
  if Rails.env.development?
    mount Localtower::Engine, at: 'localtower'
  end

  # Your other routes here:
  # ...
end
```

/!\ IMPORTANT /!\
Change your config/environments/development.rb:

```ruby
Rails.application.configure do
  # This is the default:
  # config.active_record.migration_error = :page_load

  # Change it to:
  config.active_record.migration_error = false if defined?(Localtower)

  # ...
end
```

If you know how to override this configuration in the gem instead of doing it in your app code, please open an issue and tell me your solution.

## Usage

Open your browser at [http://localhost:3000/localtower](http://localhost:3000/localtower).

## Roadmap

- Be able to use `uuid` instead of `id` as primary when creating models.
- Realtime preview of the migration files
- Better frontend validation

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

Thanks for reporting issues, I'll do my best to fix the bugs 💪

![ga](https://www.google-analytics.com/collect?v=1&tid=G-1XG3EBE2DZ&cid=555&aip=1&t=event&ec=github&ea=visit&dp=readme&dt=gem)

## Deploy

Only for official contributors.

    rm *.gem | gem build localtower.gemspec && gem push localtower-*.gem

## Notes

Do not hesitate to open issues if you have troubles using the gem.

- By Damian Le Nouaille Diez: https://damln.com
- Supported by Explicit Ruby: https://explicit-ruby.run
- Link on RubyGems.org: https://rubygems.org/gems/localtower
- Stats on BestGems.org: https://bestgems.org/gems/localtower
