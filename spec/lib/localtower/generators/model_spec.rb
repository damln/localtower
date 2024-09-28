require 'spec_helper'

module Localtower
  module Generators
    describe Model do
      context 'model 1' do
        let(:expected_migration) do
          <<-TEXT_MULTILINE.strip_heredoc
          class CreatePosts < ActiveRecord::Migration[7.2]
            disable_ddl_transaction!

            def change
              create_table :posts do |t|
                t.string :title
                t.string :tags, array: true, default: [], null: false
                t.text :content, null: false
                t.integer :likes_count, default: 0
                t.float :score
                t.jsonb :metadata, default: {}, null: false

                t.timestamps
              end
              add_index :posts, :title, unique: true
              add_index :posts, :tags, using: :gin, unique: true, algorithm: :concurrently
              add_index :posts, :content, using: :gist
              add_index :posts, :likes_count
              add_index :posts, :score
              add_index :posts, :metadata
            end
          end
          TEXT_MULTILINE
        end

        let(:expected_model) do
          <<-TEXT_MULTILINE.strip_heredoc
          class Post < ApplicationRecord
          end
          TEXT_MULTILINE
        end

        let(:attributes) { attributes_for(:post_one).deep_stringify_keys }

        it 'create a post' do
          ::Localtower::Generators::Model.new(attributes).run

          expect(File.read("#{Rails.root}/app/models/post.rb")).to eq(expected_model)
          expect(File.read(last_migration)).to eq(expected_migration)
        end
      end
    end
  end
end
