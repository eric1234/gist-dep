# https://gist.github.com/eric1234/732081
# Allows you to restore the old engine functionality of mixing code
# of the engine and the application. Less magic than the origional
# setup. For example the following will mix the User model in from an
# engine and then add the method to_s.
#
#     Rails::Engine.mixin __FILE__
#     class User < ActiveRecord::Base
#       def to_s
#         [first_name, last_name].reject(&:blank?) * ' '
#       end
#     end
#
# Will grab the matching path it finds regardless of engine. Note that the
# Rails root is automatically stripped off. The following example specifies a
# specific engine and file within that engine to load.
#
#     Rails::Engine.mixin 'app/models/user.rb', Login::Engine
module Rails
  def Engine.mixin(path=nil, engine=nil)
    path = path.sub "#{Rails.root}/", '' if path.starts_with? Rails.root.to_s
    engine ||= subclasses.find {|e| e.root.join(path).exist?}
    require_dependency engine.root.join(path).to_s
  end
end