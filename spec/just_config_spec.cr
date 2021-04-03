require "./spec_helper"

config_no_vars = "
my_config:
  key_1: 42
  key_2:
    - item_1
    - item_2
"

config_with_var = "
my_config:
  key_1: 42
  key_2:
    - \#{?HOST}
    - item_2
"

config_with_override = "
my_config:
  key_1: 42
  key_2:
    host: http://localhost
    host: \#{?HOST}
    port: 8080
    port: \#{?PORT}
"

describe JustConfig do
  it "doesn't alter config with no env variables" do
    JustConfig.interpolate(config_no_vars).should eq config_no_vars
  end

  it "interpolates environment variables" do
    interpolated = "
my_config:
  key_1: 42
  key_2:
    - http://0.0.0.0
    - item_2
"
    env = {"HOST" => "http://0.0.0.0"}
    JustConfig.interpolate(config_with_var, env).should eq interpolated
  end

  it "removes non-interpolated environment variables" do
    interpolated = "
my_config:
  key_1: 42
  key_2:
    - item_2
"
    env = {"OTHER" => "interpolated-item"}
    JustConfig.interpolate(config_with_var, env).should eq interpolated
  end

  it "overrides existing variables, where possible" do
    interpolated = "
my_config:
  key_1: 42
  key_2:
    host: http://localhost
    host: http://0.0.0.0
    port: 8080
"
    env = {"HOST" => "http://0.0.0.0"}
    JustConfig.interpolate(config_with_override, env).should eq interpolated
  end

  it "supports interpolating multiple variables" do
    interpolated = "
my_config:
  key_1: 42
  key_2:
    host: http://localhost
    host: http://0.0.0.0
    port: 8080
    port: 9090
"
    env = {"HOST" => "http://0.0.0.0", "PORT" => "9090"}
    JustConfig.interpolate(config_with_override, env).should eq interpolated
  end
end
