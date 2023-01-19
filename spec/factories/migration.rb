FactoryBot.define do
  factory :add_column, class: "Hash" do
    migration_name { "Post" }
    migrations do
      [
        {
          action: "add_column",
          table_name: "posts",
          column: "title",
          column_type: "string",
          nullable: true,
        },
        {
          action: "add_column",
          table_name: "posts",
          column: "content",
          column_type: "text",
          nullable: true,
        },
        {
          action: "add_column",
          table_name: "posts",
          column: "views",
          column_type: "integer",
          index: true,
          default: 0,
          nullable: false,
        },
        {
          action: "add_column",
          table_name: "posts",
          column: "tags",
          column_type: "array",
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
          action: "rename_column",
          table_name: "posts",
          column: "content",
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
          action: "remove_column",
          table_name: "posts",
          column: "title",
        },
        {
          action: "rename_column",
          table_name: "posts",
          column: "views",
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
          action: "change_column_type",
          table_name: "posts",
          column: "content_new",
          new_column_type: "string",
        },
        {
          action: "add_index_to_column",
          table_name: "posts",
          column: "views_by_users",
        }
      ]
    end
  end

  factory :add_index_to_column, class: "Hash" do
    migration_name { "Post" }
    migrations do
      [
        {
          action: "add_column",
          table_name: "posts",
          column: "content",
          column_type: "text",
        },
        {
          action: "add_index_to_column",
          table_name: "posts",
          column: "content",
        },
        {
          action: "add_index_to_column",
          table_name: "posts",
          column: "content_second",
          index: {
            using: 'default',
            unique: true,
          }
        },
        {
          action: "add_index_to_column",
          table_name: "posts",
          column: "content_third",
          index: {
            using: 'gin',
            algorithm: 'concurrently',
          }
        }
      ]
    end
  end

  factory :belongs_to, class: "Hash" do
    migration_name { "Post" }
    migrations do
      [
        {
          action: "belongs_to",
          table_name: "posts",
          belongs_to: "users",
        }
      ]
    end
  end

  factory :remove_index_to_column, class: "Hash" do
    migration_name { "Post" }
    migrations do
      [
        {
          action: "remove_index_to_column",
          table_name: "posts",
          column: "views_by_users",
        }
      ]
    end
  end

  factory :drop_table, class: "Hash" do
    migration_name { "Post" }
    migrations do
      [
        {
          action: "drop_table",
          table_name: "posts",
        }
      ]
    end
  end
end
