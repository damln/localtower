FactoryBot.define do
  factory :create_table, class: "Hash" do
    migration_name { "Post" }
    migrations do
      [
        {
          action: "create_table",
          table_name: "posts"
        }
      ]
    end
  end

  factory :create_table_two, class: "Hash" do
    migration_name { "User" }
    migrations do
      [
        {
          action: "create_table",
          table_name: "users"
        }
      ]
    end
  end

  factory :add_column, class: "Hash" do
    migration_name { "Post" }
    migrations do
      [
        {
          action: "add_column",
          table_name: "posts",
          column: "title",
          column_type: "string",
          index: true,
          nullable: true,
        },
        {
          action: "add_column",
          table_name: "posts",
          column: "content",
          column_type: "text",
          index: false,
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

  factory :add_column_fail, class: "Hash" do
    migration_name { "Post" }
    migrations do
      [
        {
          action: "add_column",
          table_name: "posts",
          column: "title",
          # column_type: "string",
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
          action: "add_index_to_column",
          table_name: "posts",
          column: "content_new",
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
