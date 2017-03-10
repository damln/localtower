require 'spec_helper'

module Localtower
  module Generators
    describe Relation do

      before(:all) do
        clean_files
      end

      after(:all) do
      end

      it 'belongs_to' do
        data1 = attributes_for(:post_one)
        data1["run_migrate"] = true
        ::Localtower::Generators::Model.new(data1).run

        data2 = attributes_for(:user_one)
        data2["run_migrate"] = true
        ::Localtower::Generators::Model.new(data2).run

        data = attributes_for(:belongs_to)
        data["run_migrate"] = true

        generator = ::Localtower::Generators::Migration.new(data).run

        expect(::Localtower::Tools.word_in_file?(last_migration, /add_reference :posts, :user, foreign_key: true, index: true/)).to eq(true)
        expect(File.exist?("#{Rails.root}/app/models/post.rb")).to eq(true)
        expect(File.exist?("#{Rails.root}/app/models/user.rb")).to eq(true)
        expect(::Localtower::Tools.word_in_file?("#{Rails.root}/app/models/post.rb", /class Post/)).to eq(true)
        expect(::Localtower::Tools.word_in_file?("#{Rails.root}/app/models/post.rb", /belongs_to/)).to eq(true)
        expect(::Localtower::Tools.word_in_file?("#{Rails.root}/app/models/user.rb", /class User/)).to eq(true)
        expect(::Localtower::Tools.word_in_file?("#{Rails.root}/app/models/user.rb", /has_many/)).to eq(true)

        Dir["#{Rails.root}/app/models/**/*.*"].each { |model_file| File.delete(model_file) }
      end

      it 'create a relation' do
        clean_files

        ::Localtower::Generators::Model.new(attributes_for(:post_one)).run
        ::Localtower::Generators::Model.new(attributes_for(:user_one)).run

        ::Localtower::Generators::Relation.new(attributes_for(:relation_one)).run

        expect(File.exist?("#{Rails.root}/app/models/user_post.rb")).to eq(true)

        expect(::Localtower::Tools.word_in_file?("#{Rails.root}/app/models/user_post.rb", /class UserPost/)).to eq(true)
        expect(::Localtower::Tools.word_in_file?("#{Rails.root}/db/schema.rb", /create_table "user_posts"/)).to eq(true)
        expect(::Localtower::Tools.word_in_file?("#{Rails.root}/db/schema.rb", /t.integer  "user_id"/)).to eq(true)
        expect(::Localtower::Tools.word_in_file?("#{Rails.root}/db/schema.rb", /t.integer  "post_id"/)).to eq(true)

        expect(::Localtower::Tools.word_in_file?("#{Rails.root}/app/models/user.rb", /has_many :posts, through: :user_posts/)).to eq(true)
        expect(::Localtower::Tools.word_in_file?("#{Rails.root}/app/models/user.rb", /has_many :posts/)).to eq(true)

        expect(::Localtower::Tools.word_in_file?("#{Rails.root}/app/models/post.rb", /has_many :users/)).to eq(true)
        expect(::Localtower::Tools.word_in_file?("#{Rails.root}/app/models/post.rb", /has_many :users, through: :user_posts/)).to eq(true)
      end
    end
  end
end
