require 'gli'

# Read the actions to build the CLI option parsing and then let option
# parsing process the user's request.
class GistDep::CLI
  include GLI::App

  def initialize argv
    program_desc 'Manage files in a project maintained in GitHub\'s Gist'

    desc 'Config file'
    long_desc <<-DESC
      The configuration file used to maintian the lists of gists we
      are managing.
    DESC
    arg_name 'file'
    default_value 'gist-dep.yml'
    flag %I[C config]

    pre do |global_options, options, args|
      # Setup the global instance all actions use
      GistDep::Manager.load global_options[:config]
    end

    # If exception is EOF then silently ignore. This occurs when a
    # person didn't respond to our question (i.e. Ctrl-D) and is
    # used by the testing. All other errors use GLI's standard handling
    on_error do |exception|
      !(EOFError === exception)
    end

    GistDep::Action.actions.each do |action|
      arg_name action.arguments
      desc action.desc
      long_desc action.desc_long
      command action.key do |c|
        for option in action.options
          flags = option.delete :flags
          c.flag flags, option
        end
        c.action do |global_options, options, args|
          runner = action.new
          options.each do |key, value|
            setter = "#{key}=".to_sym
            runner.send setter, value if runner.respond_to? setter
          end
          runner.arguments = args
          runner.run
        end
      end
    end

    run argv # Actually carry out option parsing
  end

end

