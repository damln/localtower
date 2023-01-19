require 'spec_helper'

describe ::Localtower::Generators::ServiceObjects::InsertIndexes do
  let(:service) { described_class.new(attributes) }

  let(:attributes) {
    [
      { 'first'  =>
        {
          'using' => 'gin',
          'algorithm' => 'concurrently',
        }
      },
      { 'third'  =>
        {
          'using' => 'gist',
          'unique' => true,
        }
      },
      { 'fourth' =>
        {
          'using' => 'default',
          'algorithm' => 'concurrently',
        }
      },
      { 'fifth'  =>
        {
          'using' => 'default',
          'unique' => true,
        }
      }
    ]
  }

  let(:base_file_content) {
    <<-MIGRATION.strip_heredoc
      class CreateTests < ActiveRecord::Migration[7.0]
        def change
          create_table :tests do |t|
            t.string  :zero
            t.string  :first
            t.string  :third
            t.string  :fourth
            t.integer :fifth

            t.timestamps
          end
          add_index :tests, :first
          add_index :tests, :third
          add_index :tests, :fourth
          add_index :tests, :fifth
        end
      end
    MIGRATION
  }

  let(:expected_file_content) {
    <<-MIGRATION.strip_heredoc
      class CreateTests < ActiveRecord::Migration[7.0]
        disable_ddl_transaction!

        def change
          create_table :tests do |t|
            t.string  :zero
            t.string  :first
            t.string  :third
            t.string  :fourth
            t.integer :fifth

            t.timestamps
          end
          add_index :tests, :first, using: :gin, algorithm: :concurrently
          add_index :tests, :third, using: :gist, unique: true
          add_index :tests, :fourth, algorithm: :concurrently
          add_index :tests, :fifth, unique: true
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
