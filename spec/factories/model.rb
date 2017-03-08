FactoryGirl.define do
  factory :post_one, class: Hash do
    model_name "Post"
    attributes [
      {
        attribute_name: "title",
        attribute_type: "string",
        index: true
      },
      {
        attribute_name: "content",
        attribute_type: "text"
      }
    ]
  end

  factory :user_one, class: Hash do
    model_name "User"
    attributes [
      {
        attribute_name: "name",
        attribute_type: "string",
        index: true,
      },
      {
        attribute_name: "metadata",
        attribute_type: "jsonb"
      },
    ]
  end

  factory :relation_one, class: Hash do
    model_one_name "User"
    model_two_name "Post"
  end
end
