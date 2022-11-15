module Localtower
  module ApplicationHelper
    def file_link(file)
      "vscode://file/#{file}"
    end
  end
end
