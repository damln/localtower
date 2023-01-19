FactoryBot.define do
  factory :post_one, class: Hash do
    model_name { 'Post' }
    attributes do
      [
        {
          'attribute_name' => 'title',
          'attribute_type' => 'string',
          'index' => {
            'using' => 'default',
            'unique' => true,
            'algorithm' => 'default',
          }
        },
        {
          'attribute_name' => 'tags',
          'attribute_type' => 'array',
          'nullable' => false,
          'default' => '[]',
          'index' => {
            'using' => 'gin',
            'unique' => true,
            'algorithm' => 'concurrently',
          }
        },
        {
          'attribute_name' => 'content',
          'attribute_type' => 'text',
          'nullable' => false,
          'index' => {
            'using' => 'gist',
            'algorithm' => 'default',
          }
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
end
