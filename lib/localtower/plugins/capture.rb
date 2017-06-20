module Localtower
  module Plugins
    class Capture
      LOG_FILE = "#{Rails.root}/log/localtower_capture.log"
      EXCLUDE_INSTANCE_VARIABLES = [
        "@_action_has_layout",
        "@_routes",
        "@_headers",
        "@_status",
        "@_request",
        "@__react_component_helper",
        "@_response",
        "@_env",
        "@env",
        "@controller",
        "@_lookup_context",
        "@_action_name",
        "@_response_body",
      ]

      class << self
        def printable(content)
          if content.respond_to?(:to_json)
            # content.to_json
            JSON.pretty_generate(content)
          else
            content.to_s
          end
        end

        def type_of(value)
          if value.instance_of?(Float); return Float.to_s; end;
          if value.instance_of?(Integer); return Integer.to_s; end;
          if value.instance_of?(String); return String.to_s; end;
          if value.instance_of?(Array); return Array.to_s; end;
          if value.instance_of?(Hash); return Hash.to_s; end;
          if value.instance_of?(ApplicationController); return ApplicationController.to_s; end;
          if value.instance_of?(NilClass); return NilClass.to_s; end;

          nil
        end
      end

      def initialize(context = nil, context_binding = nil)
        @context = context
        @context_binding = context_binding
      end

      def logs
        content = File.open(LOG_FILE).read
        return {"variables" => []} unless content.present?

        data = JSON.parse(content)
      end

      def my_logger
        @@my_logger ||= Logger.new(LOG_FILE)
        @@my_logger.formatter = proc do |severity, datetime, progname, msg|
          "#{msg}\n"
        end

        @@my_logger
      end

      def values
        hash = {}

        a = @context.send(:caller)[1] # xx/xx/app/controllers/clients/events_controller.rb:57:in `new'
        a = a.split(Rails.root.to_s).last # events_controller.rb:57:in `new'
        a = a.split("\:")

        file = a[0].strip
        line_number = a[1].strip
        method = a[2].strip.gsub("in \`", "").gsub("\'", "")

        hash["class"] = self.klass_name
        hash["method"] = "#{file}##{method}:#{line_number}"

        variables = []

        @context_binding.local_variables.each do |var|
          next if EXCLUDE_INSTANCE_VARIABLES.include?(var.to_s)

          value = @context_binding.local_variable_get(var)
          klass = self.class.type_of(value)

          variables << {
            name: var,
            value: value,
            klass: klass
          }

          if value.is_a?(ActiveRecord::AssociationRelation) and value.respond_to?(:count)
            variables << {
              name: "#{var}_count",
              value: value.count,
              klass: nil
            }
          end
        end

        @context.instance_variables.each do |var|
          next if EXCLUDE_INSTANCE_VARIABLES.include?(var.to_s)

          value = @context.instance_variable_get(var.to_sym)
          klass = self.class.type_of(value)

          variables << {
            name: var,
            value: value,
            klass: klass
          }

          if value.is_a?(ActiveRecord::AssociationRelation) and value.respond_to?(:count)
            variables << {
              name: "#{var}_count",
              value: value.count,
              klass: nil
            }
          end
        end

        hash["variables"] = variables

        hash
      end

      def klass_name
        value = if @context.class == "Class"
          @context
        else
          @context.class
        end

        value.to_s
      end

      # def context_caller
      #   @context.send(:caller)[0]
      # end

      def init
        # Clear the logs
        File.open(LOG_FILE, 'w') { |f| f.write("") }
        self
      end

      def save
        return nil if Rails.env.production?

        self.init
        json = self.values.to_json
        log "#{json}\n"
      end

      def log(str)
        my_logger.info(str)
      end
    end
  end
end
