FactoryBot.define do
  factory :add_column, class: "Hash" do
    migration_name { "Post" }
    migrations do
      [
        {
          action_name: "add_column",
          model_name: "Post",
          model_underscore: "post",
          table_name: "posts",
          column_name: "title",
          column_type: "string",
          nullable: true,
        },
        {
          action_name: "add_column",
          model_name: "Post",
          model_underscore: "post",
          table_name: "posts",
          column_name: "content",
          column_type: "text",
          nullable: true,
        },
        {
          action_name: "add_column",
          model_name: "Post",
          model_underscore: "post",
          table_name: "posts",
          column_name: "views",
          column_type: "integer",
          index: true,
          default: '0',
          nullable: false,
        },
        {
          action_name: "add_column",
          model_name: "Post",
          model_underscore: "post",
          table_name: "posts",
          column_name: "tags",
          column_type: "array",
          default: '[]',
          index: true,
          nullable: true,
        }
      ]
    end
  end

  factory :rename_column, class: "Hash" do
    migration_name { "Post" }
    migrations do
      [
        {
          action_name: "rename_column",
          model_name: "Post",
          model_underscore: "post",
          table_name: "posts",
          column_name: "content",
          new_column_name: "content_new",
        }
      ]
    end
  end

  factory :remove_column, class: "Hash" do
    migration_name { "Post" }
    migrations do
      [
        {
          action_name: "remove_column",
          model_name: "Post",
          model_underscore: "post",
          table_name: "posts",
          column_name: "title",
        },
        {
          action_name: "rename_column",
          model_name: "Post",
          model_underscore: "post",
          table_name: "posts",
          column_name: "views",
          new_column_name: "views_by_users",
        }
      ]
    end
  end

  factory :change_column_type, class: "Hash" do
    migration_name { "Post" }
    migrations do
      [
        {
          action_name: "change_column_type",
          model_name: "Post",
          model_underscore: "post",
          table_name: "posts",
          column_name: "content_new",
          new_column_type: "string",
        },
        {
          action_name: "add_index_to_column",
          model_name: "Post",
          model_underscore: "post",
          table_name: "posts",
          column_name: "views_by_users",
          index: "default"
        }
      ]
    end
  end

  factory :add_index_to_column, class: "Hash" do
    migration_name { "Post" }
    migrations do
      [
        {
          action_name: "add_column",
          model_name: "Post",
          model_underscore: "post",
          table_name: "posts",
          column_name: "content",
          column_type: "text",
        },
        {
          action_name: "add_index_to_column",
          model_name: "Post",
          model_underscore: "post",
          table_name: "posts",
          column_name: "content",
          index: "default"
        },
        {
          action_name: "add_index_to_column",
          model_name: "Post",
          model_underscore: "post",
          table_name: "posts",
          column_name: "content_second",
          index: "default",
          index_algorithm: '',
          unique: true
        },
        {
          action_name: "add_index_to_column",
          model_name: "Post",
          model_underscore: "post",
          table_name: "posts",
          column_name: "content_third",
          index: "gin",
          index_algorithm: 'concurrently',
          unique: false
        }
      ]
    end
  end

  factory :belongs_to, class: "Hash" do
    migration_name { "Post" }
    migrations do
      [
        {
          action_name: "belongs_to",
          model_name: "Post",
          model_underscore: "post",
          table_name: "posts",
          column_name: "user",
          foreign_key: true,
          index: "default"
        }
      ]
    end
  end

  factory :remove_index_to_column, class: "Hash" do
    migration_name { "Post" }
    migrations do
      [
        {
          action_name: "remove_index_to_column",
          model_name: "Post",
          model_underscore: "post",
          table_name: "posts",
          column_name: "views_by_users",
          index_name: "index_posts_on_views_by_users"

        }
      ]
    end
  end

  factory :drop_table, class: "Hash" do
    migration_name { "Post" }
    migrations do
      [
        {
          action_name: "drop_table",
          model_name: "Post",
          model_underscore: "post",
          table_name: "posts",
        }
      ]
    end
  end
end
