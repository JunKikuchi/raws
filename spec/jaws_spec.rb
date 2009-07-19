require 'rubygems'
require 'lib/jaws'
require 'spec/spec_config'

describe JAWS do
  it 'class method' do
    %w'aws_access_key_id aws_secret_access_key escape sign send'.each do |val|
      JAWS.should respond_to val.to_sym
    end
  end
end

describe JAWS::SDB do
  it 'class method' do
    %w''.each do |val|
      JAWS::SDB.should respond_to val.to_sym
    end
  end

  it 'each' do
    JAWS::SDB.each do |val|
      p val
    end
  end
end
