FactoryBot.define do
  factory :post_one, class: Hash do
    model_name { 'Post' }
    attributes do
      [
        {
          'column_name' => 'title',
          'column_type' => 'string',
          'unique' => true,
          'index' => 'default',
          'index_algorithm' => 'default'
        },
        {
          'column_name' => 'tags',
          'column_type' => 'array',
          'nullable' => false,
          'default' => '[]',
          'index' => 'gin',
          'index_algorithm' => 'concurrently',
          'unique' => true
        },
        {
          'column_name' => 'content',
          'column_type' => 'text',
          'nullable' => false,
          "index" => "gist",
          "index_algorithm" => "default"
        },
        {
          'column_name' => 'likes_count',
          'column_type' => 'integer',
          'nullable' => true,
          'default' => '0',
        },
        {
          'column_name' => 'score',
          'column_type' => 'float',
        },
        {
          'column_name' => 'metadata',
          'column_type' => 'jsonb',
          'nullable' => false,
          'default' => '{}',
        },
      ]
    end
  end

  factory :post_two, class: "Hash" do
    model_name { 'Post' }
    attributes do
      [
        {
          'column_name' => 'user',
          'column_type' => 'references',
          'foreign_key' => true
        }
      ]
    end
  end

  factory :post_three, class: "Hash" do
    model_name { 'Post' }
    attributes do
      [
        {
          'column_name' => 'user',
          'column_type' => 'references',
          'foreign_key' => false
        }
      ]
    end
  end
end
