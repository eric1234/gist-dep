require 'tempfile'

class GistDep::Action::Diff < GistDep::Action::ForEach

  self.desc = 'Shows changes made to installed gists'
  self.desc_long = <<-DESC
    Shows a diff between the installed gists on this project and the
    same gists on http://gist.github.com. Makes it easy to see what
    you will push before a push or pull before an update.
  DESC
  self.options += [{
    desc: 'Diff command to use',
    arg_name: 'path/to/diff_prog',
    default_value: 'diff -u',
    flags: %I[d diff_cmd]
  }]

  attr_accessor :diff_cmd

  def run
    super do |file|
      canonical = GistDep::File.fetch "#{file.gist_id}/#{file.filename}"
      Tempfile.open 'gist-dep-diff' do |temp|
        canonical.path = temp.path
        canonical.download
        system "#{diff_cmd} #{canonical.path} #{file.path}"
      end
    end
  end

end
