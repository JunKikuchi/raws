# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{raws}
  s.version = "0.0.11"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jun Kikuchi"]
  s.date = %q{2010-01-25}
  s.description = %q{raws}
  s.email = %q{kikuchi@bonnou.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "CHANGELOG",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/raws.rb",
     "lib/raws/http.rb",
     "lib/raws/http/ht2p.rb",
     "lib/raws/http/typhoeus.rb",
     "lib/raws/s3.rb",
     "lib/raws/s3/acl.rb",
     "lib/raws/s3/adapter.rb",
     "lib/raws/s3/metadata.rb",
     "lib/raws/s3/model.rb",
     "lib/raws/s3/owner.rb",
     "lib/raws/sdb.rb",
     "lib/raws/sdb/adapter.rb",
     "lib/raws/sdb/model.rb",
     "lib/raws/sdb/select.rb",
     "lib/raws/sqs.rb",
     "lib/raws/sqs/adapter.rb",
     "lib/raws/sqs/message.rb",
     "lib/raws/sqs/model.rb",
     "lib/raws/xml.rb",
     "lib/raws/xml/nokogiri.rb",
     "raws.gemspec",
     "spec/raws/s3/acl_spec.rb",
     "spec/raws/s3/model_spec.rb",
     "spec/raws/s3_spec.rb",
     "spec/raws/sdb/model_spec.rb",
     "spec/raws/sdb_spec.rb",
     "spec/raws/sqs_spec.rb",
     "spec/raws_spec.rb",
     "spec/spec_config.rb.example",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/JunKikuchi/raws}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{raws}
  s.test_files = [
    "spec/raws/s3/acl_spec.rb",
     "spec/raws/s3/model_spec.rb",
     "spec/raws/s3_spec.rb",
     "spec/raws/sdb/model_spec.rb",
     "spec/raws/sdb_spec.rb",
     "spec/raws/sqs_spec.rb",
     "spec/raws_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_runtime_dependency(%q<typhoeus>, [">= 0.1.14"])
      s.add_runtime_dependency(%q<ht2p>, [">= 0.0.7"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 1.4.1"])
      s.add_runtime_dependency(%q<uuidtools>, [">= 2.1.1"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<typhoeus>, [">= 0.1.14"])
      s.add_dependency(%q<ht2p>, [">= 0.0.7"])
      s.add_dependency(%q<nokogiri>, [">= 1.4.1"])
      s.add_dependency(%q<uuidtools>, [">= 2.1.1"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<typhoeus>, [">= 0.1.14"])
    s.add_dependency(%q<ht2p>, [">= 0.0.7"])
    s.add_dependency(%q<nokogiri>, [">= 1.4.1"])
    s.add_dependency(%q<uuidtools>, [">= 2.1.1"])
  end
end

