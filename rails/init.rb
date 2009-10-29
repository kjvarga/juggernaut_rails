require File.join(File.dirname(__FILE__), '../lib/juggernaut')
require File.join(File.dirname(__FILE__), '../lib/juggernaut/rails')
require File.join(File.dirname(__FILE__), '../lib/juggernaut/rails/helpers')

Juggernaut.send(:include, Juggernaut::Rails::ConvenienceMethods)
ActionView::Base.send(:include, Juggernaut::Rails::Helpers)

ActionView::Helpers::AssetTagHelper.register_javascript_expansion :juggernaut => ['juggernaut/swfobject', 'juggernaut/juggernaut']
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :juggernaut_jquery => ['juggernaut/json', 'juggernaut/juggernaut', 'juggernaut/jquerynaut', 'juggernaut/swfobject']

ActionController::Base.class_eval do
  alias_method :render_without_juggernaut, :render
  include Juggernaut::Rails::RenderExtension
  alias_method :render, :render_with_juggernaut
end

ActionView::Base.class_eval do
  alias_method :render_without_juggernaut, :render
  include Juggernaut::Rails::RenderExtension
  alias_method :render, :render_with_juggernaut
end