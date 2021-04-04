# Let your config class (or record) extend `JustConfig` to add support
# for variable interpolation on yaml representations of your config.
#
# Variables to be interpolated must appear on the right-hand side of yaml keys, e.g.
#
# db:
#   url: #{?DB_URL}
module JustConfig
  # Replaces any identifiers wrapped in `#{?}` occurring in `raw_config`
  # with corresponding values in `env`.
  # Any row corresponding to unmatched identifiers in `raw_config` will be removed.
  #
  # `raw_config`: a String in yaml format.
  # `env`: a hash-like object.
  def self.interpolate(raw_config : String, env = ENV)
    interpolated = env.keys.reduce(raw_config) { |conf, k|
      key = "\#{?" + "#{k}" + "}"
      conf.gsub(key, env[k])
    }

    # remove rows where no interpolation took place
    interpolated.gsub(/.*\{\?.*\}.*\n?/, "")
  end

  macro extended
    # Interpolates `yaml` with the given `env` variables before parsing into
    # `{{@type}}`.
    #
    # An implementation of `.from_yaml(String)` is required.
    #
    # `yaml`: a yaml representation of a `{{@type}}` instance.
    # `env`: a hash-like object.
    def self.from_yaml(yaml, env)
      {{@type}}.from_yaml(JustConfig.interpolate(yaml, env))
    end
  end
end
