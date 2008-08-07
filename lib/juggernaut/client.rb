require 'uri'
module Juggernaut
  class Client
    include Juggernaut::Miscel
    
     attr_reader   :id
     attr_accessor :session_id
     attr_reader   :connections
     @@clients = []

     class << self
       # Actually does a find_or_create_by_id
       def find_or_create(subscriber, request)
         if client = find_by_id(request[:client_id])
           client.session_id = request[:session_id]
           client.add_new_connection(subscriber)
           client
         else
           self.new(subscriber, request)
         end
       end

       def add_client(client)
         @@clients << client unless @@clients.include?(client)
       end

       # Client find methods

       def find_all
         @@clients
       end

       def find(&block)
         @@clients.select(&block).uniq
       end

       def find_by_id(id)
         find {|client| client.id == id }.first
       end

       def find_by_signature(signature)
         # signature should be unique
         find {|client| 
           client.connections.select {|connection| connection.signature == signature }.any?
         }.first
       end

       def find_by_channels(channels)
         find {|client| 
           client.has_channels?(channels)
         }
       end

       def find_by_id_and_channels(id, channels)
         find {|client| 
           client.has_channels?(channels) && client.id == id
         }.first
       end

       def send_logouts_after_timeout
         @@clients.each do |client|
           client.logout_request if !client.alive? and client.give_up? and !client.sent_logout?
         end
       end

       # Called when the server is shutting down
       def send_logouts_to_all_clients
         @@clients.each do |client|
           client.logout_request if !client.sent_logout?
         end
       end
     end

     def initialize(subscriber, request)
       @connections = []
       @id         = request[:client_id]
       @session_id = request[:session_id]
       add_new_connection(subscriber)
     end

     def to_json
       {
         :id => @id, 
         :session_id => @session_id
       }.to_json
     end

     def add_new_connection(subscriber)
       @connections << subscriber
     end

     def subscription_request(channels)
       return true unless options[:subscription_url]
       post_request(options[:subscription_url], channels)
     end

     def logout_connection_request(channels)
       return true unless options[:logout_connection_url]
       post_request(options[:logout_connection_url], channels)
     end

     def logout_request
       return true unless options[:logout_url]
       @sent_logout = true
       post_request(options[:logout_url])
     end

     def sent_logout?
       !!@sent_logout
     end

     def send_message(msg, channels = nil)
       @connections.each do |em|
         em.broadcast(msg) if !channels or channels.empty? or em.has_channels?(channels)
       end
     end

     def has_channels?(channels)
       @connections.each do |em|
         return true if em.has_channels?(channels)
       end
       false
     end

     def remove_channels!(channels)
       @connections.each do |em|
         em.remove_channels!(channels)
       end
     end

     def alive?
       @connections.select{|em| em.alive? }.any?
     end

     def give_up?
       @connections.select {|em| em.logout_timeout and Time.now > em.logout_timeout }.any?
     end

   private

     def post_request(url, channels = [])
       url = URI.parse(url)
       params = []
       params << "client_id=#{id}" if id
       params << "session_id=#{session_id}" if session_id
       channels.each {|chan| params << "channels[]=#{chan}" }
       url.query = params.join('&')
       begin         
         open(url.to_s, "User-Agent" => "Ruby/#{RUBY_VERSION}")
       rescue => e
         logger.debug("Bad response from #{url.to_s}: #{e}")
         return false
       end
       true
     end   
   end
 end