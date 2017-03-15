# Localtower

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

Add to your ./Gemfile:

    # In your Gemfile

    group :development do
      gem "localtower"
    end

If you want the latest master branch:

    # In your Gemfile

    group :development do
      gem "localtower", github: "damln/localtower"
    end

In your terminal:

    bundle install

Add to your config/routes.rb:

    # in config/routes.rb

    if Rails.env.development?
      mount Localtower::Engine, at: "localtower"
    end

## Usage

Open your browser at: `http://localhost:3000/localtower`

## RSpec

Create a .env file inside the spec/dummy folder with the credentials to your PostgreSQL Database. It should look like this:

spec/dummy/.env:

    LOCALTOWER_PG_USERNAME="admin"
    LOCALTOWER_PG_PASSWORD="root_or_smething"

Run the spec:

    bundle install
    bundle exec rspec spec/

Notes:
Tests are currently very slow because this is testing rails commands so it boots the rails for each test. Zeus or spring should be introced.

## Contribute

Thanks for reporting issues, I'll make my best.
