module Localtower
  module ApplicationHelper
    def subl_link_to(name, file, &block)
      name ||= file
      if block_given?
        str = capture(&block)
      else
        str = name
      end
      link_to str, "subl://open/?url=file://#{file}"
    end

    def to_json_print(hash)
      # str = hash.to_json
      # str.gsub(/,"/, ',<br>"').gsub(/\"\:/, '": ').html_safe
      hash.to_json
    end
  end
end
