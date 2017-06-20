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

      def initialize(context = nil, context_binding = nil)
        @context = context
        @context_binding = context_binding
      end

      def logs
        content = File.open(LOG_FILE).read
        return [] unless content.present?

        data = JSON.parse(content)

        data.map do |key, value|
          if value.respond_to?(:to_json)
            value = JSON.pretty_generate(value)
          end

          {
            variable: key,
            value: value,
          }
        end
      end

      def my_logger
        @@my_logger ||= Logger.new(LOG_FILE)
        @@my_logger.formatter = proc do |severity, datetime, progname, msg|
          "#{msg}\n"
          # "[#{datetime}] | #{msg}\n"
        end

        @@my_logger
      end

      def values
        hash = {}

        @context_binding.local_variables.each do |var|
          next if EXCLUDE_INSTANCE_VARIABLES.include?(var.to_s)
          hash[var] = @context_binding.local_variable_get(var)

          if hash[var].is_a?(ActiveRecord::AssociationRelation)
            hash["count_#{var}"] = hash[var].count
          end
        end

        @context.instance_variables.each do |var|
          next if EXCLUDE_INSTANCE_VARIABLES.include?(var.to_s)

          Rails.logger.debug("-------------var")
          Rails.logger.debug(var)

          hash[var] = @context.instance_variable_get(var)

          if hash[var].is_a?(ActiveRecord::AssociationRelation)
            hash["count_#{var}"] = hash[var].count
          end
        end

        hash
      end

      def klass_name
        if @context.class == "Class"
          @context
        else
          @context.class
        end
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
