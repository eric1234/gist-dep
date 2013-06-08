class GistDep::Action::Remove < GistDep::Action::ForEach

  self.arguments = 'gist_id[/filename]'
  self.desc = 'Removes a gist file from the project'
  self.desc_long = <<-DESC
    Will remove the specified gist file from the project. If only the
    gist_id is given then all files from that gist will be removed.
  DESC

  def run
    # To avoid them accidently zapping all files
    raise ArgumentError, 'gist not specified' unless arguments.first

    super do |file|
      self.class.io.say "Removing #{file.filename}"
      GistDep::Manager.instance.remove file
    end

    GistDep::Manager.instance.save
  end

end
