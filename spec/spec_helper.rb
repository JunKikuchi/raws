$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'raws'
require 'spec'
require 'spec/autorun'
require 'spec/spec_config'

Spec::Runner.configure do |config|
  
end
