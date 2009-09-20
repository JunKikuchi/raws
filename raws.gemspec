# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{raws}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jun Kikuchi"]
  s.date = %q{2009-09-20}
  s.description = %q{raws}
  s.email = %q{kikuchi@bonnou.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "CHANGELOG",
     "COPYING",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/raws.rb",
     "lib/raws/s3.rb",
     "lib/raws/s3/adapter.rb",
     "lib/raws/sdb.rb",
     "lib/raws/sdb/adapter.rb",
     "lib/raws/sdb/model.rb",
     "lib/raws/sdb/select.rb",
     "lib/raws/sqs.rb",
     "lib/raws/sqs/adapter.rb"
  ]
  s.homepage = %q{http://github.com/JunKikuchi/raws}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{raws}
  s.test_files = [
    "spec/raws/s3_spec.rb",
     "spec/raws/sdb/model_spec.rb",
     "spec/raws/sdb_spec.rb",
     "spec/raws/sqs_spec.rb",
     "spec/raws_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
