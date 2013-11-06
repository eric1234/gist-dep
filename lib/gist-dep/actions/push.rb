class GistDep::Action::Push < GistDep::Action::ForEach

  self.arguments = 'gist_id[/filename]'
  self.desc = 'Send changes to http://gist.github.com'
  self.desc_long = <<-DESC
    Any changes made to the specified gist files are pushed up to
    http://gist.github.com. If the filename is not specified then all
    files from the specified gist_id will be pushed.
  DESC

  def run
    client = GistDep::Gist.client

    # Technically a user could create an anonymous gist. But since the
    # goal is to re-use code it seems a throwaway gist is not in line
    # with that mission. So force them to login so they can hopefully
    # track it down later
    raise ArgumentError, 'You must login first' unless client.token_authenticated?

    # To avoid an accidental mass update
    raise ArgumentError, 'gist not specified' unless arguments.first

    super do |file|
      gist = GistDep::Gist.new file.gist_id
      if gist.owner == client.user.login
        file.save
        self.class.io.say "#{file.filename} saved to gist #{file.gist_id}"
      else
        fork = gist.fork_by client.user.login
        fork = client.fork_gist file.gist_id unless fork
        self.class.io.say "#{file.filename} fork saved to #{fork.id} from gist #{file.gist_id}"
        file = file.dup
        file.gist_id = fork.id
        file.save
      end
    end
  end

end
