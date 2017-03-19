require 'spec_helper'

describe ::Localtower::Generators::ServiceObjects::InsertDefaults do

  let(:latest_migration) do
    Tempfile.new('foo').tap do |file|
      file.puts base_file_structure_array
      file.rewind
    end
  end

  let(:attributes) {
    [
      { 'first'  => "true"  },
      { 'third'  => "nil"   },
      { 'fourth' => "false" },
      { 'fifth'  => "0"     }
    ]
  }

  let(:base_file_structure_array) {
    [
      "class CreateTests < ActiveRecord::Migration[5.0]\n",
      "  def change\n",
      "    create_table :tests do |t|\n",
      "      t.string  :first\n",
      "      t.integer :second\n",
      "      t.string  :third\n",
      "      t.string  :fourth\n",
      "      t.integer :fifth\n",
      "\n",
      "      t.timestamps\n",
      "    end\n",
      "    add_index :tests, :first\n",
      "  end\n",
      "end\n"
    ]
  }

  let(:expected_file_structure_array) {
    [
      "class CreateTests < ActiveRecord::Migration[5.0]\n",
      "  def change\n",
      "    create_table :tests do |t|\n",
      "      t.string  :first, default: true\n",
      "      t.integer :second\n",
      "      t.string  :third, default: nil\n",
      "      t.string  :fourth, default: false\n",
      "      t.integer :fifth, default: 0\n",
      "\n",
      "      t.timestamps\n",
      "    end\n",
      "    add_index :tests, :first\n",
      "  end\n",
      "end\n"
    ]
  }

  let(:service) { described_class.new(attributes) }

  before do
    allow(service).to receive(:latest_migration).and_return(latest_migration)
    service.call
  end

  it 'inserts default values for attributes' do
    lines_array = File.readlines(latest_migration)
    expect(lines_array).to match_array expected_file_structure_array
  end
end
