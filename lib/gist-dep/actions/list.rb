class GistDep::Action::List < GistDep::Action

  self.desc = 'Lists all installed gist files'
  self.desc_long = <<-DESC
    Will list all the installed gist files on the current project.
  DESC

  def run
    for file in GistDep::Manager.instance.files
      self.class.io.say "#{file.gist_id}/#{file.filename} -> #{file.path}"
    end
  end
end
