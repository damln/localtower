require 'spec_helper'

describe ::Localtower::Generators::ServiceObjects::InsertNullable do
  let(:service) { described_class.new(attributes) }

  let(:attributes) {
    [
      'first',
      'third',
      'fourth'
    ]
  }

  let(:base_file_content) {
    <<-MIGRATION.strip_heredoc
      class CreateTests < ActiveRecord::Migration[7.0]
        def change
          create_table :tests do |t|
            t.string  :first
            t.integer :second
            t.string  :third
            t.string  :fourth, default: 'foo'
            t.integer :fifth

            t.timestamps
          end
          add_index :tests, :first
        end
      end
    MIGRATION
  }

  let(:expected_file_content) {
    <<-MIGRATION.strip_heredoc
      class CreateTests < ActiveRecord::Migration[7.0]
        def change
          create_table :tests do |t|
            t.string  :first, null: false
            t.integer :second
            t.string  :third, null: false
            t.string  :fourth, null: false, default: 'foo'
            t.integer :fifth

            t.timestamps
          end
          add_index :tests, :first
        end
      end
    MIGRATION
  }

  before do
    File.open("#{Rails.root}/db/migrate/0_migration_name_.rb", 'w') { |f| f.write(base_file_content) }
  end

  it 'works' do
    service.call

    expect(File.read(last_migration)).to eq(expected_file_content)
  end
end
