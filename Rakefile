require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "juggernaut_rails"
    gemspec.summary = "A push server written in Ruby with Rails integration."
    gemspec.email = "info@eribium.org"
    gemspec.homepage = "http://juggernaut.rubyforge.org"
    gemspec.rubyforge_project = 'juggernaut'
    gemspec.description = <<-END
      The Juggernaut Gem for Ruby on Rails aims to revolutionize your Rails app by letting the server initiate a connection and push data to the client. In other words your app can have a real time connection to the server with the advantage of instant updates. Although the obvious use of this is for chat, the most exciting prospect for me is collaborative cms and wikis.

      This Gem bundles Alex MacCaw's Juggernaut Gem and Rails plugin into one, and extends its Rails intergration for a simpler install and setup.
      END
    gemspec.authors = ["Alex MacCaw"]
    gemspec.require_paths = ['lib', 'lib/juggernaut']
    gemspec.files = FileList['[A-Z]*',
                       '{bin,lib,media,rails,test,rails}/**/*']
    gemspec.add_dependency 'eventmachine', '>= 0.10.0'
    gemspec.add_dependency 'json', '>= 1.1.2'
    gemspec.add_dependency 'escape'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
