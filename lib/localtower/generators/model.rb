module Localtower
  module Generators
    class Model
      def initialize(opts)
        @opts = JSON[opts.to_json]
      end

      def run
        if not @opts['attributes'] or not @opts['model_name'].present?
          return nil
        end

        attributes_list = []

        @opts['attributes'].each do |attribute_data|
          str = "#{attribute_data["attribute_name"]}:#{attribute_data["attribute_type"]}"
          str << ":index" if attribute_data["index"]

          attributes_list << str
        end

        attributes_str = attributes_list.join(" ")
        cmd = "rails g model #{@opts['model_name'].camelize} #{attributes_str}"

        ::Localtower::Tools.perform_cmd(cmd, false)

        if @opts['run_migrate']
          ::Localtower::Tools.perform_cmd('rake db:migrate', false)
          # ::Localtower::Tools.perform_cmd('rake db:migrate RAILS_ENV=test', false)
        end

        self
      end
    end
  end
end
