class GistDep::Action::Add < GistDep::Action

  self.arguments = 'gist_id[/filename]'
  self.desc = 'Installs a gist file to the current project'
  self.desc_long = <<-DESC
    Provided either a gist id or a gist_id/filename it will install
    the gist into the current project optionally at the specified path.
  DESC
  self.options += [{
    desc: 'Install path',
    arg_name: 'install/to/path',
    flags: %I[p path]
  }]

  attr_accessor :path

  def run
    raise ArgumentError, 'gist not specified' unless arguments.first

    begin
      file = GistDep::File.fetch arguments.first
    rescue GistDep::TooManyFiles
      self.class.io.choose do |menu|
        menu.prompt = "Please choose the file you wish to import?"
        $!.files.each do |filename|
          menu.choice filename do
            file = GistDep::File.fetch "#{arguments.first}/#{filename}"
          end
        end
      end
    end

    raise ArgumentError,
      "#{file.filename} from gist #{file.gist_id} already installed" unless
      GistDep::Manager.instance.find("#{file.gist_id}/#{file.filename}").empty?

    msg = "Adding #{file.filename} from gist #{file.gist_id}"
    if path
      file.path = path
      msg += " to #{path}"
    end

    self.class.io.say msg
    GistDep::Manager.instance.add file
    GistDep::Manager.instance.save
  end

end
