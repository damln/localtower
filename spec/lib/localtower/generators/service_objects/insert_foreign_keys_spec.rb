require 'spec_helper'

describe ::Localtower::Generators::ServiceObjects::InsertForeignKeys do
  let(:service) { described_class.new(attributes) }

  before do
    File.open("#{Rails.root}/db/migrate/0_migration_name_.rb", 'w') { |f| f.write(base_file_content) }
  end

  context "when foreign_key is true" do
    let(:attributes) {
      [
        { 'user'  =>
          {
            'foreign_key' => true,
          }
        },
      ]
    }

    let(:base_file_content) {
      <<-MIGRATION.strip_heredoc
      class CreatePosts < ActiveRecord::Migration[7.2]
        def change
          create_table :posts do |t|
            t.references :user, null: false

            t.timestamps
          end
        end
      end
      MIGRATION
    }

    let(:expected_file_content) {
      <<-MIGRATION.strip_heredoc
      class CreatePosts < ActiveRecord::Migration[7.2]
        def change
          create_table :posts do |t|
            t.references :user, null: false, foreign_key: true

            t.timestamps
          end
        end
      end
      MIGRATION
    }

    it 'works' do
      service.call

      expect(File.read(last_migration_pending)).to eq(expected_file_content)
    end
  end

  context "when foreign_key is false" do
    let(:attributes) {
      [
        { 'user'  =>
          {
            'foreign_key' => false,
          }
        },
      ]
    }

    let(:base_file_content) {
      <<-MIGRATION.strip_heredoc
      class CreatePosts < ActiveRecord::Migration[7.2]
        def change
          create_table :posts do |t|
            t.references :user, null: false, foreign_key: true

            t.timestamps
          end
        end
      end
      MIGRATION
    }

    let(:expected_file_content) {
      <<-MIGRATION.strip_heredoc
      class CreatePosts < ActiveRecord::Migration[7.2]
        def change
          create_table :posts do |t|
            t.references :user, null: false

            t.timestamps
          end
        end
      end
      MIGRATION
    }

    it 'works' do
      service.call

      expect(File.read(last_migration_pending)).to eq(expected_file_content)
    end
  end
end
