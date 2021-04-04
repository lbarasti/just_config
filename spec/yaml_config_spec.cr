require "./spec_helper"
require "yaml"

record DbConfig, host : String, username : String, password : String do
  include YAML::Serializable
end

record MyConfig, max_users : Int32?, db : DbConfig do
  include YAML::Serializable
  extend JustConfig
end

describe MyConfig do
  it "interpolates a given key-value hash" do
    env_vars = {"MAX_USERS" => 42, "HOST" => "hello.com", "PASSWORD" => "s3cret"}
    c = MyConfig.from_yaml(File.read("./spec/config.yml"), env_vars)
    c.max_users.should eq 42
    c.db.username.should eq "admin"
    c.db.host.should eq "hello.com"
    c.db.password.should eq "s3cret"
  end

  it "supports missing values" do
    c = MyConfig.from_yaml(File.read("./spec/config.yml"), {"HOST" => "hello.com"})
    c.max_users.should eq nil
    c.db.username.should eq "admin"
    c.db.host.should eq "hello.com"
    c.db.password.should eq "a-secret"
  end
end