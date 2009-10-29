require 'escape'

namespace :juggernaut do
  desc "Install the Juggernaut js and swf files into your Rails application."
  task :install => :environment do    
    require 'fileutils'
    
    here = File.join(File.dirname(__FILE__), '../../../')
    there = ::Rails.root

    FileUtils.mkdir_p("#{there}/public/javascripts/juggernaut/")
    FileUtils.mkdir_p("#{there}/public/juggernaut/")

    puts "Installing Juggernaut..."
    FileUtils.cp("#{here}/media/swfobject.js", "#{there}/public/javascripts/juggernaut/")
    FileUtils.cp("#{here}/media/juggernaut.js", "#{there}/public/javascripts/juggernaut/")
    FileUtils.cp("#{here}/media/juggernaut.swf", "#{there}/public/juggernaut/")
    FileUtils.cp("#{here}/media/expressinstall.swf", "#{there}/public/juggernaut/")

    FileUtils.cp("#{here}/media/juggernaut.yml",       "#{there}/config/") unless File.exist?("#{there}/config/juggernaut.yml")
    FileUtils.cp("#{here}/media/juggernaut_hosts.yml", "#{there}/config/") unless File.exist?("#{there}/config/juggernaut_hosts.yml")
    puts "Juggernaut has been successfully installed."
    puts
    puts "Please refer to the readme file #{File.expand_path(here)}/README"    
  end

  namespace :install do
    desc "Install the Juggernaut jQuery JavaScript files into your Rails application."
    task :jquery => :environment do
      require 'fileutils'
      
      here = File.join(File.dirname(__FILE__), '../../../')
      there = ::Rails.root
      
      FileUtils.cp("#{here}/media/jquerynaut.js", "#{there}/public/javascripts/juggernaut/")
      FileUtils.cp("#{here}/media/json.js", "#{there}/public/javascripts/juggernaut/")
      puts "Installed the Juggernaut jQuery JavaScript files to public/javascripts/juggernaut/"
    end
  end
  
  desc 'Compile the juggernaut flash file'
  task :compile_flash do
    `mtasc -version 8 -header 1:1:1 -main -swf media/juggernaut.swf media/juggernaut.as`
  end
  
  desc "Start the Juggernaut server"
  task 'start' => :environment do
    run_juggernaut('-d')
  end

  desc "Stop the Juggernaut server"
  task 'stop' => :environment do
    run_juggernaut('-k')
  end
  
  def run_juggernaut(extra_options=[])
    defaults = Juggernaut::Rails.default_options
    extra_options = [extra_options] unless extra_options.is_a?(Array)
    extra_options << '-e' if Rails.env.development?
    FileUtils.cd(Rails.root) do
      command = ['juggernaut', '-c', defaults[:config_path], '-P', defaults[:pid_path], '-l', defaults[:log_path]] + extra_options
      system(Escape.shell_command(command))
    end
  end
end
