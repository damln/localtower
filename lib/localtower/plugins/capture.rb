module Localtower
  module Plugins
    class Capture
      LOG_FILE = lambda { "#{Rails.root}/log/localtower_capture.log" }
      LOG_PATH = lambda { "#{Rails.root}/log" }
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
        @context = context # self
        @context_binding = context_binding # binding
      end

      def logs
        list = []

        Dir["#{LOG_PATH.call}/localtower_capture_*.json"].each do |file|
          json = JSON.parse(open(file).read)
          list << json
        end

        list
      end

      def my_logger
        @@my_logger ||= Logger.new(LOG_FILE.call)
        @@my_logger.formatter = proc do |severity, datetime, progname, msg|
          "#{msg}\n"
        end

        @@my_logger
      end

      def values
        hash = {}

        callers = @context.send(:caller)
        a = callers[1] # xx/xx/app/controllers/clients/events_controller.rb:57:in `new'
        a = a.split(Rails.root.to_s).last # events_controller.rb:57:in `new'
        a = a.split("\:")


        file = a[0].strip
        line_number = a[1].strip
        method = a[2].strip.gsub("in \`", "").gsub("\'", "")

        sublime_path = "#{callers[1].split(":")[0]}:#{line_number}"

        hash["class"] = self.klass_name
        hash["file"] = "#{file}##{method}:#{line_number}"
        hash["method"] = method
        hash["md5"] = Digest::MD5.hexdigest(hash["file"])
        hash["type"] = "CAPTURE_METHOD"
        hash["time"] = Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L')

        variables = []

        @context_binding.local_variables.each do |var|
          next if EXCLUDE_INSTANCE_VARIABLES.include?(var.to_s)

          value = @context_binding.local_variable_get(var)
          klass = self.class.type_of(value)

          data = {
            type: 'CAPTURE',
            time: Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L'),
            event_name: var,
            identifier: nil,
            returned: value,
            meta: {
              from_klass: hash["class"],
              from_method: hash["method"],
              klass: klass.to_s,
              method: method.to_s,
              # arguments: data[:arguments],
              callers: callers,
              # table_name: data[:table_name],
              # sql: data[:sql],
              sublime_path: sublime_path,
              file: hash["file"],
              line: line_number
            }
          }

          variables << data
        end

        @context.instance_variables.each do |var|
          next if EXCLUDE_INSTANCE_VARIABLES.include?(var.to_s)

          value = @context.instance_variable_get(var.to_sym)
          klass = self.class.type_of(value)

          data = {
            type: 'CAPTURE',
            time: Time.now.utc.strftime('%Y-%m-%d %H:%M:%S.%L'),
            event_name: var,
            identifier: nil,
            returned: value,
            meta: {
              from_klass: hash["class"],
              from_method: hash["method"],
              klass: klass.to_s,
              method: method.to_s,
              # arguments: data[:arguments],
              callers: callers,
              # table_name: data[:table_name],
              # sql: data[:sql],
              sublime_path: sublime_path,
              file: hash["file"],
              line: line_number
            }
          }

          variables << data

          # if value.is_a?(ActiveRecord::AssociationRelation) and value.respond_to?(:count)
          #   variables << {
          #     name: "#{var}_count",
          #     value: value.count,
          #     klass: nil
          #   }
          # end
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

      def clear
        Dir["#{LOG_PATH.call}/localtower_capture_*.json"].each do |file|
          File.delete(file)
        end

        self
      end

      def save
        return nil if Rails.env.production?
        self.clear

        data = self.values
        json = data.to_json
        file = "#{LOG_PATH.call}/localtower_capture_#{data['md5']}.json"

        File.open(file, 'w') { |f| f.write(json) }
        # log "#{json}\n"
      end

      def log(str)
        my_logger.info(str)
      end
    end
  end
end
