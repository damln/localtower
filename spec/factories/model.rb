FactoryBot.define do
  factory :post_one, class: Hash do
    model_name { 'Post' }
    attributes do
      [
        {
          'attribute_name' => 'title',
          'attribute_type' => 'string',
          'unique' => true,
          'index' => 'default',
          'index_algorithm' => 'default'
        },
        {
          'attribute_name' => 'tags',
          'attribute_type' => 'array',
          'nullable' => false,
          'default' => '[]',
          'index' => 'gin',
          'index_algorithm' => 'concurrently',
          'unique' => true
        },
        {
          'attribute_name' => 'content',
          'attribute_type' => 'text',
          'nullable' => false,
          "index" => "gist",
          "index_algorithm" => "default"
        },
        {
          'attribute_name' => 'likes_count',
          'attribute_type' => 'integer',
          'nullable' => true,
          'default' => '0',
        },
        {
          'attribute_name' => 'score',
          'attribute_type' => 'float',
        },
        {
          'attribute_name' => 'metadata',
          'attribute_type' => 'jsonb',
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
          'attribute_name' => 'user',
          'attribute_type' => 'references',
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
          'attribute_name' => 'user',
          'attribute_type' => 'references',
          'foreign_key' => false
        }
      ]
    end
  end
end
