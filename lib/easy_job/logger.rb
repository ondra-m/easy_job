module EasyJob
  class Logger < ::Logger

    def initialize(*args)
      super $stdout
      self.formatter = proc do |severity, datetime, progname, msg|
        time = datetime.strftime('%H:%M:%S')
        "#{severity.first}, [#{time}] #{msg}\n"
      end
    end

  end
end
