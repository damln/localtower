![Gem](https://img.shields.io/gem/v/localtower) ![Gem](https://img.shields.io/gem/dt/localtower?label=gem%20downloads)

<p align="center">
<img src="https://raw.githubusercontent.com/damln/localtower/master/public/com/twitter-cover-3.png" alt="Localtower">
</p>

## Introduction

![New Model](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v2.0.0/Screenshot%202024-11-18%20at%2022.44.30.jpg)

**- What is Localtower?**

Localtower is a Rails Engine mountable in development environment to help you generate migrations for your Rails application.
It's like ActiveAdmin or Sidekiq UI.
You plug it in your `config/routes.rb` and it works out of the box.
Check the _Installation_ section below for more details.

**- How Localtower works?**

Localtower gives you a UI to create models and migrations. It will generate a migration file like you would do with `rails generate migration add_index_to_users`. You will see the generated file in `db/migrate/` folder.

**- Why creating a UI for Rails migrations?**

Rails migrations are well documented in the official [Rails Guides](https://guides.rubyonrails.org/active_record_migrations.html) but we often tend to forget some commands or do typo errors. Like writing `add_index :user, :email` instead of `add_index :users, :email` (did you spot the typo?). Working from a UI with a fixed list of commands reduces the chance of making errors.

**- When I'm using Localtower, can I still generate migrations from the command line?**

Of course! Localtower does not lock you up. You can still generate migrations like you did before. Localtower is just a migration generator. You can also generate a migration from Localtower and then edit it manually before running `rails db:migrate`

**- What does happen when I want to remove Localtower?**

You just have to remove the gem from your `Gemfile`, run `bundle`, remove the engine in `config/routes.rb`, and that's it! All your previous migrations will stay in `db/migrate/`. You are never locked up with Localtower. You can install or uninstall anytime. Remember, it is just a UI to generate files. Do not hesitate to [open an issue on Github](https://github.com/damln/localtower/issues) and tell me why you don't want it anymore. It will be very valuable for me to understand what I can do better ❤.

**- Cool, but there are some migration options that are not available in Localtower, what can I do?**

Localtower doesn't implement all the Rails Migrations API. I focused on the most common scenarios. If you need to do something tricky in your migrations, you can still edit the migrations manually. You are also welcome to [open an issue on Github](https://github.com/damln/localtower/issues) to ask for a specific feature. I'm always open to extend the possibilities of Localtower.

## Screenshots

### Create a model

![New Model](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v2.0.0/Screenshot%202024-11-18%20at%2022.44.30.jpg)

### Create a migration

![New Migration](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v2.0.0/Screenshot%202024-11-18%20at%2022.48.21.jpg)

### See the Migrations (and migrate)

![Migrations](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v2.0.0/Screenshot%202024-11-18%20at%2022.50.11.jpg)

## Installation

Please use the best localtower version: `>= 2`
See installation process below.

Compatibility:

- Rails >= 5.2
- Ruby >= 2.3

Add to your `Gemfile` file:

```ruby
group :development do
  gem 'localtower', '~> 2'
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

**⚠ IMPORTANT ⚠**

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

To access the UI, run your local rails server and open your browser at [http://localhost:3000/localtower](http://localhost:3000/localtower).

## Full scenario

### Demo (2min)

[![Localtower v2 demo](https://raw.githubusercontent.com/damln/localtower/master/public/com/localtower-play.png)](https://www.youtube.com/watch?v=Bd01fm3xuko)

### Create a model

![](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v2.0.0/Screenshot%202024-11-18%20at%2022.44.30.jpg)

It will create a migration file:

![](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v2.0.0/Screenshot%202024-11-18%20at%2022.44.42.jpg)

### Create a migration

![](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v2.0.0/Screenshot%202024-11-18%20at%2022.48.21.jpg)

It will generate a migration file:

![](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v2.0.0/Screenshot%202024-11-18%20at%2022.48.51.jpg)

### Create another model

Now, we add a `Book` model:

![](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v2.0.0/Screenshot%202024-11-18%20at%2022.50.04.jpg)

### All the migrations generated

![](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v2.0.0/Screenshot%202024-11-18%20at%2022.50.19.jpg)

### Files generated

Every action made from the UI will generate native Rails migration files.
Exactly like the `rails generate` command.
But instead of generating files in the console, they are generated in the `db/migrate` folder.

- The models:
![](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v2.0.0/Screenshot%202024-11-18%20at%2022.51.47.jpg)
![](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v2.0.0/Screenshot%202024-11-18%20at%2022.51.48.jpg)

- The migration files:
![](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v2.0.0/Screenshot%202024-11-18%20at%2022.52.18.jpg)
![](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v2.0.0/Screenshot%202024-11-18%20at%2022.52.26.jpg)

- The final schema:
![](https://raw.githubusercontent.com/damln/localtower/master/public/screenshots/v2.0.0/Screenshot%202024-11-18%20at%2022.52.38.jpg)


## Upgrading

I recommend you to upgrade to the latest version which is `2.X.X`.
Be sure you have this in your `Gemfile`:
```ruby
group :development do
  gem 'localtower', '~> 2'
end
```

To upgrade, just use the latest version of Localtower.

```
bundle update localtower
```

Then restart your server.

## Contribute

Thanks for reporting issues, I'll do my best to fix the bugs 💪

![ga](https://www.google-analytics.com/collect?v=1&tid=G-1XG3EBE2DZ&cid=555&aip=1&t=event&ec=github&ea=visit&dp=readme&dt=gem)

## Run test

If you want to contribute to the gem:

Create a `spec/dummy/.env` file with the credentials to your PostgreSQL Database. It should look like this:

```
LOCALTOWER_PG_USERNAME="admin"
LOCALTOWER_PG_PASSWORD="root_or_smething"
```

drop / create database:

```bash
cd spec/dummy
bundle exec rails db:drop
bundle exec rails db:create
rm app/models/*.rb
```

Run the spec:

```bash
bundle install
bundle exec rspec spec/
```

## Deploy latest gem version

Only for official contributors.

    git tag vX.X.X # change by last version
    git push --tags
    rm *.gem
    gem build localtower.gemspec
    gem push localtower-*.gem

## Notes

Do not hesitate to open issues if you have troubles using the gem.

- By Damian Le Nouaille:
  - Twitter: https://twitter.com/damian_lnd
  - Website: https://damln.com
- Link on RubyGems.org: https://rubygems.org/gems/localtower
- Stats on BestGems.org (30k+ downloads): https://bestgems.org/gems/localtower
