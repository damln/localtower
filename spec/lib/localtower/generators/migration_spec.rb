require 'spec_helper'

module Localtower
  module Generators
    describe Migration do
      it 'add_column' do
        data = attributes_for(:add_column)[:migrations]

        generator = ::Localtower::Generators::Migration.new(data).run

        expect(word_in_file?(last_migration_pending, /add_column :posts, :title, :string/)).to eq(true)
        expect(word_in_file?(last_migration_pending, /add_column :posts, :content, :text/)).to eq(true)
        expect(word_in_file?(last_migration_pending, /add_column :posts, :views, :integer, default: 0, null: false/)).to eq(true)
        expect(word_in_file?(last_migration_pending, /add_column :posts, :tags, :string, default: \[\], array: true/)).to eq(true)
      end

      it 'remove_column' do
        data = attributes_for(:remove_column)[:migrations]

        generator = ::Localtower::Generators::Migration.new(data).run

        expect(word_in_file?(last_migration_pending, /remove_column :posts, :title/)).to eq(true)
        expect(word_in_file?(last_migration_pending, /rename_column :posts, :views, :views_by_users/)).to eq(true)
      end

      it 'rename_column' do
        data = attributes_for(:rename_column)[:migrations]

        generator = ::Localtower::Generators::Migration.new(data).run

        expect(word_in_file?(last_migration_pending, /rename_column :posts, :content, :content_new/)).to eq(true)
      end

      it 'change_column_type' do
        data = attributes_for(:change_column_type)[:migrations]

        generator = ::Localtower::Generators::Migration.new(data).run

        expect(word_in_file?(last_migration_pending, /add_index :posts, :views_by_users/)).to eq(true)
        expect(word_in_file?(last_migration_pending, /change_column :posts, :content_new, :string/)).to eq(true)
      end

      it 'add_index_to_column' do
        data = attributes_for(:add_index_to_column)[:migrations]

        generator = ::Localtower::Generators::Migration.new(data).run

        expect(word_in_file?(last_migration_pending, /disable_ddl_transaction!/)).to eq(true)
        expect(word_in_file?(last_migration_pending, /add_index :posts, :content/)).to eq(true)
        expect(word_in_file?(last_migration_pending, /add_index :posts, :content_second, unique: true/)).to eq(true)
        expect(word_in_file?(last_migration_pending, /add_index :posts, :content_third, using: :gin, algorithm: :concurrently/)).to eq(true)
      end

      it 'belongs_to' do
        data = attributes_for(:belongs_to)[:migrations]

        generator = ::Localtower::Generators::Migration.new(data).run

        expect(word_in_file?(last_migration_pending, /add_reference :posts, :user, foreign_key: true, index: true/)).to eq(true)
      end

      it 'remove_index_to_column' do
        data = attributes_for(:remove_index_to_column)[:migrations]

        generator = ::Localtower::Generators::Migration.new(data).run

        expect(word_in_file?(last_migration_pending, /remove_index :posts, name: :index_posts_on_views_by_users/)).to eq(true)
      end

      it 'drop_table' do
        data = attributes_for(:drop_table)[:migrations]

        generator = ::Localtower::Generators::Migration.new(data).run

        expect(word_in_file?(last_migration_pending, /drop_table :posts/)).to eq(true)
      end
    end
  end
end
