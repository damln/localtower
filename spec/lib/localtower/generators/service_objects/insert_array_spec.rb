require 'spec_helper'

describe ::Localtower::Generators::ServiceObjects::InsertArray do
  let(:service) { described_class.new(attributes) }

  let(:attributes) {
    ['tags']
  }

  let(:base_file_content) {
    <<-MIGRATION.strip_heredoc
      class CreateTests < ActiveRecord::Migration[7.0]
        def change
          create_table :tests do |t|
            t.string :tags

            t.timestamps
          end
        end
      end
    MIGRATION
  }

  let(:expected_file_content) {
    <<-MIGRATION.strip_heredoc
      class CreateTests < ActiveRecord::Migration[7.0]
        def change
          create_table :tests do |t|
            t.string :tags, array: true

            t.timestamps
          end
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
