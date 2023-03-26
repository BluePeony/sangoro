Gem::Specification.new do |s|
  s.name         = "sangoro"
  s.version      = "1.0.0"
  s.author       = "BluePeony"
  s.email        = "blue.peony2314@gmail.com"
  s.homepage     = "https://github.com/BluePeony/sangoro"
  s.summary      = "Command line tool to change the EXIF creation time stamp of JPEGs and PNGs"
  s.description  = File.read(File.join(File.dirname(__FILE__), 'README.md'))
  s.licenses     = ['MIT']

  s.files         = Dir["{bin,lib,spec}/**/*"] + %w(LICENSE README.md)
  s.test_files    = Dir["spec/**/*"]
  s.executables   = [ 'sangoro' ]

  s.required_ruby_version = '>=1.9'
  s.add_development_dependency 'rspec', '~> 2.8', '>= 2.8.0'
end
