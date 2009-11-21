require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'raws'
    gem.summary = %Q{raws}
    gem.description = %Q{raws}
    gem.email = "kikuchi@bonnou.com"
    gem.homepage = "http://github.com/JunKikuchi/raws"
    gem.authors = ["Jun Kikuchi"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_dependency 'typhoeus',  '>=0.1.9'
    gem.add_dependency 'ht2p',      '>=0.0.5'
    gem.add_dependency 'nokogiri',  '>=1.3.3'
    gem.add_dependency 'uuidtools', '>=2.0.0'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ht2p #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
