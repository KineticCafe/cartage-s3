# -*- encoding: utf-8 -*-
# stub: cartage-s3 2.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "cartage-s3".freeze
  s.version = "2.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Austin Ziegler".freeze]
  s.date = "2018-04-12"
  s.description = "cartage-s3 is a plug-in for {cartage}[https://github.com/KineticCafe/cartage]\nto upload the built package to Amazon's S3 or a service with a similar\ninterface.\n\nCartage provides a repeatable means to create a package for a Rails application\nthat can be used in deployment with a configuration tool like Ansible, Chef,\nPuppet, or Salt.".freeze
  s.email = ["aziegler@kineticcafe.com".freeze]
  s.extra_rdoc_files = ["Contributing.md".freeze, "History.md".freeze, "Licence.md".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "cartage-s3-cli.md".freeze]
  s.files = ["Contributing.md".freeze, "History.md".freeze, "Licence.md".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "Rakefile".freeze, "cartage-s3-cli.md".freeze, "lib/cartage/commands/s3.rb".freeze, "lib/cartage/plugins/s3.rb".freeze, "test/minitest_config.rb".freeze, "test/test_cartage_s3.rb".freeze]
  s.homepage = "https://github.com/KineticCafe/cartage-s3/".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]
  s.required_ruby_version = Gem::Requirement.new("~> 2.0".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "cartage-s3 is a plug-in for {cartage}[https://github.com/KineticCafe/cartage] to upload the built package to Amazon's S3 or a service with a similar interface".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<cartage>.freeze, ["~> 2.0"])
      s.add_runtime_dependency(%q<fog-aws>.freeze, ["< 3.0", ">= 1.0"])
      s.add_runtime_dependency(%q<mime-types>.freeze, ["< 4.0", ">= 2.0"])
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.11"])
      s.add_development_dependency(%q<rake>.freeze, [">= 10.0"])
      s.add_development_dependency(%q<rdoc>.freeze, ["~> 4.2"])
      s.add_development_dependency(%q<hoe-doofus>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<hoe-gemspec2>.freeze, ["~> 1.1"])
      s.add_development_dependency(%q<hoe-git>.freeze, ["~> 1.5"])
      s.add_development_dependency(%q<hoe-travis>.freeze, ["~> 1.2"])
      s.add_development_dependency(%q<minitest-autotest>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<minitest-bisect>.freeze, ["~> 1.2"])
      s.add_development_dependency(%q<minitest-bonus-assertions>.freeze, ["~> 2.0"])
      s.add_development_dependency(%q<minitest-focus>.freeze, ["~> 1.1"])
      s.add_development_dependency(%q<minitest-moar>.freeze, ["~> 0.0"])
      s.add_development_dependency(%q<minitest-pretty_diff>.freeze, ["~> 0.1"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.7"])
      s.add_development_dependency(%q<hoe>.freeze, ["~> 3.17"])
    else
      s.add_dependency(%q<cartage>.freeze, ["~> 2.0"])
      s.add_dependency(%q<fog-aws>.freeze, ["< 3.0", ">= 1.0"])
      s.add_dependency(%q<mime-types>.freeze, ["< 4.0", ">= 2.0"])
      s.add_dependency(%q<minitest>.freeze, ["~> 5.11"])
      s.add_dependency(%q<rake>.freeze, [">= 10.0"])
      s.add_dependency(%q<rdoc>.freeze, ["~> 4.2"])
      s.add_dependency(%q<hoe-doofus>.freeze, ["~> 1.0"])
      s.add_dependency(%q<hoe-gemspec2>.freeze, ["~> 1.1"])
      s.add_dependency(%q<hoe-git>.freeze, ["~> 1.5"])
      s.add_dependency(%q<hoe-travis>.freeze, ["~> 1.2"])
      s.add_dependency(%q<minitest-autotest>.freeze, ["~> 1.0"])
      s.add_dependency(%q<minitest-bisect>.freeze, ["~> 1.2"])
      s.add_dependency(%q<minitest-bonus-assertions>.freeze, ["~> 2.0"])
      s.add_dependency(%q<minitest-focus>.freeze, ["~> 1.1"])
      s.add_dependency(%q<minitest-moar>.freeze, ["~> 0.0"])
      s.add_dependency(%q<minitest-pretty_diff>.freeze, ["~> 0.1"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.7"])
      s.add_dependency(%q<hoe>.freeze, ["~> 3.17"])
    end
  else
    s.add_dependency(%q<cartage>.freeze, ["~> 2.0"])
    s.add_dependency(%q<fog-aws>.freeze, ["< 3.0", ">= 1.0"])
    s.add_dependency(%q<mime-types>.freeze, ["< 4.0", ">= 2.0"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.11"])
    s.add_dependency(%q<rake>.freeze, [">= 10.0"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 4.2"])
    s.add_dependency(%q<hoe-doofus>.freeze, ["~> 1.0"])
    s.add_dependency(%q<hoe-gemspec2>.freeze, ["~> 1.1"])
    s.add_dependency(%q<hoe-git>.freeze, ["~> 1.5"])
    s.add_dependency(%q<hoe-travis>.freeze, ["~> 1.2"])
    s.add_dependency(%q<minitest-autotest>.freeze, ["~> 1.0"])
    s.add_dependency(%q<minitest-bisect>.freeze, ["~> 1.2"])
    s.add_dependency(%q<minitest-bonus-assertions>.freeze, ["~> 2.0"])
    s.add_dependency(%q<minitest-focus>.freeze, ["~> 1.1"])
    s.add_dependency(%q<minitest-moar>.freeze, ["~> 0.0"])
    s.add_dependency(%q<minitest-pretty_diff>.freeze, ["~> 0.1"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.7"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.17"])
  end
end
