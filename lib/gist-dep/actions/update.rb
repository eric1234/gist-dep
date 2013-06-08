class GistDep::Action::Update < GistDep::Action::ForEach

  self.desc = 'Updates an installed gist file with the latest version'
  self.desc_long = <<-DESC
    Will update the specified gist file with the latest from
    http://gist.github.com. If the filename is not given then all
    installed files from the gist are updated. If the gist_id is not
    given then all managed files are updated.
  DESC

  def run
    super do |file|
      self.class.io.say "Downloading latest #{file.filename} from gist #{file.gist_id}"
      file.download
    end
  end

end
