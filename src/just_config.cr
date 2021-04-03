# TODO: Write documentation for `JustConfig`
module JustConfig
  extend JustConfig

  def interpolate(raw_config : String, env = ENV)
    interpolated = env.keys.reduce(raw_config) { |conf, k|
      key = "\#{?" + "#{k}" + "}"
      conf.gsub(key, env[k])
    }

    # remove rows where no interpolation took place
    interpolated.gsub(/.*\{\?.*\}.*\n?/, "")
  end
end
