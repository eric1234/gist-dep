require 'highline'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/class/subclasses'

class GistDep::Action

  # For interacting with the user
  class_attribute :io
  self.io = HighLine.new $stdin, $stdout

  class_attribute :arguments
  class_attribute :desc
  class_attribute :desc_long

  class_attribute :options
  self.options = []

  attr_reader :arguments

  def initialize
    @arguments = []
  end

  class << self

    # Determines the syntax used to trigger an action.
    def key
      name.split('::').last.downcase
    end

    # Returns a list of all loaded actions. This is basically just
    # a specialization of ActiveSupport's subclasses method. It finds
    # all leaf nodes (descendents that have no descendents)
    def actions
      descendants.find_all {|d| d.descendants.empty?}
    end

  end

end

require 'gist-dep/actions/add'
require 'gist-dep/actions/list'
require 'gist-dep/actions/for_each'
require 'gist-dep/actions/remove'
require 'gist-dep/actions/update'
require 'gist-dep/actions/diff'
require 'gist-dep/actions/login'
require 'gist-dep/actions/push'
