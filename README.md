# just_config

A shard to substitute environment variables into your yaml config.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     just_config:
       github: lbarasti/just_config
   ```

2. Run `shards install`

## Usage
Require `just_config` and let your config class (or record) extend `JustConfig`.

```crystal
require "yaml"
require "just_config"

record DbConfig, host : String, username : String, password : String do
  include YAML::Serializable
  extend JustConfig
end
```

Provided that your config class defines a `from_yaml(yaml : String)` class method, you'll be able to invoke `from_yaml(yaml : String, env)`, where `env` is any hash-like object.

This is straightforward if your config definition includes [YAML::Serializable](https://crystal-lang.org/api/1.0.0/YAML/Serializable.html) - as in the example above.

Now, in your config file, wrap any environment variable you'd like to replace in `#{?}`:
```yml
# config.yml
host: #{?HOST}
username: admin
password: a-secret
password: #{?PASSWORD}
```

You'll be able to interpolate [environment variables](https://crystal-lang.org/api/1.0.0/ENV.html) into you config as follows.
```crystal
DbConfig.from_yaml(File.read("./path/to/config.yml"), ENV)
# => DbConfig(host: "localhost", username: "admin", password: "super-secret")
```

Alternatively, you can interpolate keys in any hash-like object with the following:
```crystal
DbConfig.from_yaml(File.read("./path/to/config.yml"), {"HOST" => "0.0.0.0"})
# => DbConfig(host: "0.0.0.0", username: "admin", password: "a-secret")
```

### Low-level API
Invoke `JustConfig.interpolate(raw_config : String, env = ENV)` to replace any key wrapped in `#{?}` appearing in `raw_config` with the corresponding value in `env`.

```crystal
config = "
db:
  max_connections: \#{?DB_MAX_CONN}
  url: postgresql://postgres:mysecretpassword@localhost
  url: \#{?DB_URL}
"
env = {"DB_URL" => "postgresql://admin:supers3cr3t@amazonaws.com"}

JustConfig.interpolate(config, env)
# => "
# db:
#   url: postgresql://postgres:mysecretpassword@localhost
#   url: postgresql://admin:supers3cr3t@amazonaws.com
# "
```

Where a key is present in the configuration, but missing in `env`, the corresponding configuration row will be removed - see `max_connections` row in the example above.

## Development

To get started with development, just make sure that `crystal spec` runs with success on your machine. The project has no external dependencies.

## Contributing

1. Fork it (<https://github.com/lbarasti/just_config/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [lbarasti](https://github.com/lbarasti) - creator and maintainer
