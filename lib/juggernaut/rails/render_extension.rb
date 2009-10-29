module Juggernaut::Rails
  module RenderExtension
    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      # We can't protect these as ActionMailer complains

      def render_with_juggernaut(options = nil, extra_options = {}, &block)
        if options == :juggernaut or (options.is_a?(Hash) and options[:juggernaut])
          begin
            if @template.respond_to?(:_evaluate_assigns_and_ivars, true)
              @template.send(:_evaluate_assigns_and_ivars)
            else
              @template.send(:evaluate_assigns)
            end
        
            generator = ActionView::Helpers::PrototypeHelper::JavaScriptGenerator.new(@template, &block)            
            render_for_juggernaut(generator.to_s, options.is_a?(Hash) ? options[:juggernaut] : nil)
          ensure
            erase_render_results
            reset_variables_added_to_assigns
          end
        else
          render_without_juggernaut(options, extra_options, &block)
        end
      end

      def render_juggernaut(*args)
        juggernaut_options = args.last.is_a?(Hash) ? args.pop : {}
        render_for_juggernaut(render_to_string(*args), juggernaut_options)
      end

      def render_for_juggernaut(data, options = {})
        if !options or !options.is_a?(Hash)
          return Juggernaut.send_to_all(data)
        end
    
        case options[:type]
          when :send_to_all
            Juggernaut.send_to_all(data)
          when :send_to_channels
            juggernaut_needs options, :channels
            Juggernaut.send_to_channels(data, options[:channels])
          when :send_to_channel
            juggernaut_needs options, :channel
            Juggernaut.send_to_channel(data, options[:channel])
          when :send_to_client
            juggernaut_needs options, :client_id
            Juggernaut.send_to_client(data, options[:client_id])
          when :send_to_clients
            juggernaut_needs options, :client_ids
            Juggernaut.send_to_clients(data, options[:client_ids])
          when :send_to_client_on_channel
            juggernaut_needs options, :client_id, :channel
            Juggernaut.send_to_clients_on_channel(data, options[:client_id], options[:channel])
          when :send_to_clients_on_channel
            juggernaut_needs options, :client_ids, :channel
            Juggernaut.send_to_clients_on_channel(data, options[:client_ids], options[:channel])
          when :send_to_client_on_channels
            juggernaut_needs options, :client_ids, :channels
            Juggernaut.send_to_clients_on_channel(data, options[:client_id], options[:channels])
          when :send_to_clients_on_channels
            juggernaut_needs options, :client_ids, :channels
            Juggernaut.send_to_clients_on_channel(data, options[:client_ids], options[:channels])
        end
      end

      def juggernaut_needs(options, *args)
        args.each do |a|
          raise "You must specify #{a}" unless options[a]
        end
      end
    end
  end
end