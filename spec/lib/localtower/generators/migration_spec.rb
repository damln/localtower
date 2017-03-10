require 'spec_helper'

module Localtower
  module Generators
    describe Migration do
      before(:all) do
        clean_files
      end

      after(:all) do
      end

      it 'create_table' do
        data = attributes_for(:create_table)
        data["run_migrate"] = true

        generator = ::Localtower::Generators::Migration.new(data).run

        expect(::Localtower::Tools.word_in_file?(last_migration, /create_table :posts/)).to eq(true)
      end

      it 'create_table_two' do
        data = attributes_for(:create_table_two)
        data["run_migrate"] = true

        generator = ::Localtower::Generators::Migration.new(data).run

        expect(::Localtower::Tools.word_in_file?(last_migration, /create_table :users/)).to eq(true)
      end

      it 'add_column' do
        data = attributes_for(:add_column)
        data["run_migrate"] = true

        generator = ::Localtower::Generators::Migration.new(data).run

        expect(::Localtower::Tools.word_in_file?(last_migration, /add_column :posts, :tags, :text, default: \[\], array: true/)).to eq(true)
        expect(::Localtower::Tools.word_in_file?(last_migration, /add_index :posts, :tags, using: :gin/)).to eq(true)
        expect(::Localtower::Tools.word_in_file?(last_migration, /add_column :posts, :views, :integer, default: 0, null: false, index: true/)).to eq(true)
        expect(::Localtower::Tools.word_in_file?(last_migration, /add_column :posts, :content, :text/)).to eq(true)
        expect(::Localtower::Tools.word_in_file?(last_migration, /add_column :posts, :title, :string, index: true/)).to eq(true)
      end

      it 'add_column fail' do
        data = attributes_for(:add_column_fail)
        data["run_migrate"] = true

        generator = ::Localtower::Generators::Migration.new(data).run

        expect(::Localtower::Tools.word_in_file?(last_migration, /add_column :posts, :tags, :text, default: \[\], array: true/)).to eq(false)
        expect(::Localtower::Tools.word_in_file?(last_migration, /add_index :posts, :tags, using: :gin/)).to eq(false)
        expect(::Localtower::Tools.word_in_file?(last_migration, /add_column :posts, :views, :integer, default: 0, null: false, index: true/)).to eq(false)
        expect(::Localtower::Tools.word_in_file?(last_migration, /add_column :posts, :content, :text/)).to eq(false)
        expect(::Localtower::Tools.word_in_file?(last_migration, /add_column :posts, :title, :string, index: true/)).to eq(false)
      end

      it 'rename_column' do
        data = attributes_for(:rename_column)
        data["run_migrate"] = true

        generator = ::Localtower::Generators::Migration.new(data).run

        expect(::Localtower::Tools.word_in_file?(last_migration, /rename_column :posts, :content, :content_new/)).to eq(true)
      end

      it 'remove_column' do
        data = attributes_for(:remove_column)
        data["run_migrate"] = true

        generator = ::Localtower::Generators::Migration.new(data).run

        expect(::Localtower::Tools.word_in_file?(last_migration, /remove_column :posts, :title/)).to eq(true)
        expect(::Localtower::Tools.word_in_file?(last_migration, /rename_column :posts, :views, :views_by_users/)).to eq(true)
      end

      it 'change_column_type' do
        data = attributes_for(:change_column_type)
        data["run_migrate"] = true

        generator = ::Localtower::Generators::Migration.new(data).run

        expect(::Localtower::Tools.word_in_file?(last_migration, /add_index :posts, :views_by_users/)).to eq(true)
        expect(::Localtower::Tools.word_in_file?(last_migration, /change_column :posts, :content_new, :string/)).to eq(true)
      end

      it 'add_index_to_column' do
        data = attributes_for(:add_index_to_column)
        data["run_migrate"] = true

        generator = ::Localtower::Generators::Migration.new(data).run

        expect(::Localtower::Tools.word_in_file?(last_migration, /add_index :posts, :content_new/)).to eq(true)
      end

      it 'remove_index_to_column' do
        data = attributes_for(:remove_index_to_column)
        data["run_migrate"] = true

        generator = ::Localtower::Generators::Migration.new(data).run

        expect(::Localtower::Tools.word_in_file?(last_migration, /remove_index :posts, :views_by_users/)).to eq(true)
      end

      it 'drop_table' do
        data = attributes_for(:drop_table)
        data["run_migrate"] = true

        generator = ::Localtower::Generators::Migration.new(data).run

        expect(::Localtower::Tools.word_in_file?(last_migration, /drop_table :posts, force: :cascade/)).to eq(true)
      end
    end
  end
end
