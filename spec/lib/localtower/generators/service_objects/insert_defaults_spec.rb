require 'spec_helper'

describe ::Localtower::Generators::ServiceObjects::InsertDefaults do
  let(:service) { described_class.new(attributes) }

  let(:attributes) {
    [
      { 'first'  => "true" },
      { 'third'  => "nil" },
      { 'fourth' => "false" },
      { 'foo' => "{}" },
      { 'fifth'  => "0" }
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
            t.string  :fourth
            t.jsonb  :foo
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
            t.string  :first, default: true
            t.integer :second
            t.string  :third, default: nil
            t.string  :fourth, default: false
            t.jsonb  :foo, default: {}
            t.integer :fifth, default: 0

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

    expect(File.read(last_migration_pending)).to eq(expected_file_content)
  end
end
