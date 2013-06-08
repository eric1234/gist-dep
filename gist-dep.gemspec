Gem::Specification.new do |s|
  s.name = 'gist-dep'
  s.version = '0.1.0'
  s.homepage = 'http://github.com/eric1234/gist-dep'
  s.author = 'Eric Anderson'
  s.email = 'eric@pixelwareinc.com'
  s.executables << 'gist-dep'
  s.add_dependency 'octokit'
  s.add_dependency 'faraday'
  s.add_dependency 'faraday_middleware'
  s.add_dependency 'gli'
  s.add_dependency 'highline'
  s.add_dependency 'activesupport'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'dotenv'
  s.files = Dir['lib/**/*.rb'] + Dir['bin/*']
  s.extra_rdoc_files << 'README.rdoc'
  s.rdoc_options << '--main' << 'README.rdoc'
  s.summary = 'A gem-like tool for managing small reusable code snippets in a project'
  s.description = <<-DESCRIPTION
    Useful for small bits of functionality that are used repeatly in
    different projects and/or by different developers. Monkey-patches,
    client-side JavaScript behavior, common styles, etc are great examples.

    Anytime you want to re-use code but the amount of code is so small it
    is silly to create a library gist-dep is your answer.
  DESCRIPTION
end
