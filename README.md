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
if Rails.env.development?
  mount Localtower::Engine, at: "localtower"
end
```

## Usage

Open your browser at [http://localhost:3000/localtower](http://localhost:3000/localtower).

## Logger Usage (Capture plugin)

You can put this line anywhere in your code:

    Localtower::Plugins::Capture.new(self, binding).save

For example:

    def my_method
      user = User.find(1)
      some_data = {foo: "bar"}

      Localtower::Plugins::Capture.new(self, binding).save
    end

Then go to the Localtower intercave here: [http://localhost:3000/localtower/logs](http://localhost:3000/localtower/logs) and you will see the variables `user` and `some_data` in the UI.

### Notes for the Capture plugin:

The value for each variable will try to call `.to_json`. If you have a huge collection of models likes `@users` you will see all the collection as an Array.

## RSpec

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
