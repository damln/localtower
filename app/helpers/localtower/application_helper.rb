module Localtower
  module ApplicationHelper
    def subl_link_to(name, file, &block)
      name ||= file
      if block_given?
        str = capture(&block)
      else
        str = name
      end

      link_to str, file_link(file)
    end

    def file_link(file)
      "vscode://file/#{file}"
    end

    def to_json_print(hash)
      hash.to_json
    end
  end
end
