module Juggernaut # :nodoc:
  module Rails
    module Helpers

      def juggernaut(options = {})
        random_host = Juggernaut::Rails.random_host
        options = {
          :host                 => (random_host[:public_host] || random_host[:host]),
          :port                 => (random_host[:public_port] || random_host[:port]),
          :width                => '0px',
          :height               => '0px',
          :session_id           => request.session_options[:id],
          :swf_address          => "/juggernaut/juggernaut.swf",
          :ei_swf_address       => "/juggernaut/expressinstall.swf",
          :flash_version        => 8,
          :flash_color          => "#fff",
          :swf_name             => "juggernaut_flash",
          :bridge_name          => "juggernaut",
          :debug                => (RAILS_ENV == 'development'),
          :reconnect_attempts   => 3,
          :reconnect_intervals  => 3
        }.merge(options)
        javascript_tag "new Juggernaut(#{options.to_json});"
      end
    end
  end
end
