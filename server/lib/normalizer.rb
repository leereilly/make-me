module MakeMe
  class Normalizer
    def initialize(inputs, output, args)
      bounds        = {
                        :length => (ENV['MAKE_ME_MAX_X'] || 285).to_f.to_s,
                        :width  => (ENV['MAKE_ME_MAX_Y'] || 153).to_f.to_s,
                        :height => (ENV['MAKE_ME_MAX_Z'] || 155).to_f.to_s,
                      }
      default_args  = {
                        :scale => 1.0,
                        :count => 1,
                        :bounds => bounds
                      }

      @args = default_args.merge(args)
      @inputs, @output = inputs, output
    end

    def count
      @args[:count] || 1
    end

    def scale
      @args[:scale] || 1.0
    end

    def bounds
      @args[:bounds]
    end

    # Runs stltwalker with the given arguments and blocks. Returns if the
    # normalization worked properly
    def normalize!
      inputs = @inputs * count
      args = ['-p', '-o', @output, "--scale=#{scale}"]
      if bounds
        args.concat([
                      '-L', bounds[:length],
                      '-W', bounds[:width],
                      '-H', bounds[:height]
                    ])
      end

      normalize = ['./vendor/stltwalker/stltwalker', *args, *inputs]
      begin
        pid = Process.spawn(*normalize, :err => :out, :out => [MakeMe::App::LOG_FILE, "w"])
        _pid, status = Process.wait2 pid

        status.exitstatus == 0
      rescue Errno::ENOENT
        # If we cannot find stltwalker, we fail
        false
      end
    end
  end
end
