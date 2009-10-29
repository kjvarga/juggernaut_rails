require "socket"

module Juggernaut::Rails
  module ConvenienceMethods
    
    def self.included(base) #:nodoc:
      #raise "included jugs"
      base.class_eval do
        extend ClassMethods
      end
    end
  
    module ClassMethods
    
      def send_to_all(data)
        fc = {
          :command   => :broadcast,
          :body      => data, 
          :type      => :to_channels,
          :channels  => []
        }
        send_data(fc)
      end
    
      def send_to_channels(data, channels)
        fc = {
          :command   => :broadcast,
          :body      => data, 
          :type      => :to_channels,
          :channels  => channels
        }
        send_data(fc)
      end
      alias send_to_channel send_to_channels
    
      def send_to_clients(data, client_ids)
        fc = {
          :command    => :broadcast,
          :body       => data, 
          :type       => :to_clients,
          :client_ids => client_ids
        }
        send_data(fc)
      end
      alias send_to_client send_to_clients
    
      def send_to_clients_on_channels(data, client_ids, channels)
        fc = {
          :command    => :broadcast,
          :body       => data, 
          :type       => :to_clients,
          :client_ids => client_ids,
          :channels   => channels
        }
        send_data(fc)
      end
      alias send_to_clients_on_channel send_to_clients_on_channels
      alias send_to_client_on_channels send_to_clients_on_channels
    
      def remove_channels_from_clients(client_ids, channels)
        fc = {
          :command    => :query,
          :type       => :remove_channels_from_client,
          :client_ids => client_ids,
          :channels   => channels
        }
        send_data(fc)
      end
      alias remove_channel_from_client remove_channels_from_clients
      alias remove_channels_from_client remove_channels_from_clients
    
      def remove_all_channels(channels)
        fc = {
          :command    => :query,
          :type       => :remove_all_channels,
          :channels   => channels
        }
        send_data(fc)
      end
    
      def show_clients
        fc = {
          :command  => :query,
          :type     => :show_clients
        }
        send_data(fc, true).flatten
      end
    
      def show_client(client_id)
        fc = {
          :command    => :query,
          :type       => :show_client,
          :client_id  => client_id
        }
        send_data(fc, true).flatten[0]
      end
    
      def show_clients_for_channels(channels)
        fc = {
          :command    => :query,
          :type       => :show_clients_for_channels,
          :channels   => channels
        }
        send_data(fc, true).flatten
      end
      alias show_clients_for_channel show_clients_for_channels

      def send_data(hash, response = false)
        hash[:channels]   = Array(hash[:channels])   if hash[:channels]
        hash[:client_ids] = Array(hash[:client_ids]) if hash[:client_ids]
      
        res = []
        hosts.each do |address|
          begin
            hash[:secret_key] = address[:secret_key] if address[:secret_key]
          
            @socket = TCPSocket.new(address[:host], address[:port])
            # the \0 is to mirror flash
            @socket.print(hash.to_json + Juggernaut::Server::CR)
            @socket.flush
            res << @socket.readline(Juggernaut::Server::CR) if response
          ensure
            @socket.close if @socket and !@socket.closed?
          end
        end
        res.collect {|r| ActiveSupport::JSON.decode(r.chomp!(Juggernaut::Server::CR)) } if response
      end
    
    private
    
      def hosts
        Juggernaut::Rails.hosts
      end
    
    end
  end
end