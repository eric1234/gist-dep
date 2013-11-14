Gem::Specification.new do |s|
  s.name = 'gist-dep'
  s.version = '0.1.1'
  s.homepage = 'http://github.com/eric1234/gist-dep'
  s.author = 'Eric Anderson'
  s.email = 'eric@pixelwareinc.com'
  s.license = 'Public domain'
  s.executables << 'gist-dep'
  s.add_dependency 'octokit', '~> 2.0'
  s.add_dependency 'faraday', '~> 0.0'
  s.add_dependency 'faraday_middleware', '~> 0.0'
  s.add_dependency 'gli', '~> 2.0'
  s.add_dependency 'highline', '~> 1.0'
  s.add_dependency 'activesupport', '~> 4.0'
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
