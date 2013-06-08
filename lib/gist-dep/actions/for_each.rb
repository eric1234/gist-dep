# Several actions do some operation on each gist specified
# (remove, update, diff and push). This class abstracts the pattern of
# determining what files need to be operated on leaving the subclass
# simply to provide the actual action to carry out.
class GistDep::Action::ForEach < GistDep::Action

  self.arguments = '[gist_id[/filename]]'

  def run
    files = if arguments.first
      GistDep::Manager.instance.find arguments.first
    else
      GistDep::Manager.instance.files
    end
    if files.empty?
      raise ArgumentError, "#{arguments.first} not found"
    else
      for file in files
        yield file if block_given?
      end
    end
  end

end
