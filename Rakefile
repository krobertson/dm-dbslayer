require 'rubygems'
require 'spec'
require 'rake/clean'
require 'rake/gempackagetask'
require 'spec/rake/spectask'
require 'pathname'

CLEAN.include '{coverage,log,pkg}/'

spec = Gem::Specification.new do |s|
  s.name             = 'dm-dbslayer'
  s.version          = '0.2.0'
  s.platform         = Gem::Platform::RUBY
  s.has_rdoc         = true
  s.extra_rdoc_files = %w[ README.textile MIT-LICENSE TODO ]
  s.summary          = 'DataMapper plugin for interfacing with DBSlayer-enabled databases'
  s.description      = s.summary
  s.author           = 'Ken Robertson'
  s.email            = 'ken@invalidlogic.com'
  s.homepage         = 'http://github.com/krobertson/dm-dbslayer'
  s.require_path     = 'lib'
  s.files            = FileList[ '{lib,spec}/**/*.rb', 'spec/spec.opts', 'Rakefile', *s.extra_rdoc_files ]
  s.add_dependency('dm-core', '= 0.9.0')
  s.add_dependency('json_pure')
end

task :default => [ :spec ]

WIN32 = (PLATFORM =~ /win32|cygwin/) rescue nil
SUDO  = WIN32 ? '' : ('sudo' unless ENV['SUDOLESS'])

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Install #{spec.name} #{spec.version}"
task :install => [ :package ] do
  sh "#{SUDO} gem install pkg/#{spec.name}-#{spec.version} --no-update-sources", :verbose => false
end

desc 'Run specifications'
Spec::Rake::SpecTask.new(:spec) do |t|
  if File.exists?('spec/spec.opts')
    t.spec_opts << '--options' << 'spec/spec.opts'
  end
  t.spec_files = Pathname.glob(Pathname.new(__FILE__).dirname + 'spec/**/*_spec.rb')
    unless ENV['NO_RCOV']
      t.rcov = true
      t.rcov_opts << '--exclude' << "spec,gems"
      t.rcov_opts << '--text-summary'
      t.rcov_opts << '--sort' << 'coverage' << '--sort-reverse'
    end
end

# Console 
desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -r data_mapper -r dm-migrations -I lib"
end