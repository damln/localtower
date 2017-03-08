require 'spec_helper'

module Localtower
  module Generators
    describe Model do

      before(:each) do
      end

      after(:all) do
      end

      it 'create a post' do
        data = attributes_for(:post_one)
        data["run_migrate"] = true

        ::Localtower::Generators::Model.new(data).run

        expect(File.exist?("#{Rails.root}/app/models/post.rb")).to eq(true)
        expect(::Localtower::Tools.word_in_file?("#{Rails.root}/app/models/post.rb", /class Post/)).to eq(true)

        expect(::Localtower::Tools.word_in_file?("#{Rails.root}/db/schema.rb", /create_table "posts"/)).to eq(true)
        expect(::Localtower::Tools.word_in_file?("#{Rails.root}/db/schema.rb", /t.string   "title"/)).to eq(true)
        expect(::Localtower::Tools.word_in_file?("#{Rails.root}/db/schema.rb", /t.text     "content"/)).to eq(true)
        expect(::Localtower::Tools.word_in_file?("#{Rails.root}/db/schema.rb", /t.index \["title"\], name: "index_posts_on_title", using: :btree/)).to eq(true)
      end

      it 'create a user' do
        data = attributes_for(:user_one)
        data["run_migrate"] = true

        ::Localtower::Generators::Model.new(data).run

        expect(File.exist?("#{Rails.root}/app/models/user.rb")).to eq(true)
        expect(::Localtower::Tools.word_in_file?("#{Rails.root}/app/models/user.rb", /class User/)).to eq(true)
        expect(::Localtower::Tools.word_in_file?("#{Rails.root}/db/schema.rb", /create_table "users"/)).to eq(true)
        expect(::Localtower::Tools.word_in_file?("#{Rails.root}/db/schema.rb", /t.string   "name"/)).to eq(true)
        expect(::Localtower::Tools.word_in_file?("#{Rails.root}/db/schema.rb", /t.jsonb    "metadata"/)).to eq(true)
        expect(::Localtower::Tools.word_in_file?("#{Rails.root}/db/schema.rb", /t.index \["name"\], name: "index_users_on_name", using: :btree/)).to eq(true)
      end
    end
  end
end
