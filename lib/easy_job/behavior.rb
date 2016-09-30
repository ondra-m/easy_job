# Behavior model
#
# NOT used in current version
# Just and idea

##
# EasyJob::Behavior
#
# Container for behavior definition
#
module EasyJob
  class Behavior

    @@behaviors = {}

    def self.define(name, &block)
      @@behaviors[name] = new(name, &block)
    end

    def self.get(name)
      @@behaviors[name]
    end

    def initialize(name, &block)
      @name = name
      instance_eval(&block)
    end

    def on_create
      if block_given?
        @on_create = Proc.new
      else
        @on_create || proc{}
      end
    end

  end
end

##
# EasyJob::TaskWrapper
#
# Modified wrapper
#
module EasyJob
  class TaskWrapper

    def initialize(task_class, args)
      @behaviors = Array(task_class.behaviors)
      @behaviors.map!{|b| Behavior.get(b) }
      @behaviors.compact!

      @behaviors.each{|b| instance_eval(&b.on_initialize) }
    end

    def perform
    end

  end
end


##
# Definition of behavior
#
EasyJob::Behavior.define 'Database' do

  on_create do
    @connection_attempt = 0
  end

  on_perform do |task|
    begin
      ActiveRecord::Base.connection_pool.with_connection { task.run }
    rescue ActiveRecord::ConnectionTimeoutError
      @connection_attempt += 1
      if @connection_attempt > max_db_connection_attempts
        log_error 'Max ConnectionTimeoutError'
        return
      else
        log_warn "ConnectionTimeoutError attempt=#{@connection_attempt}"
        retry
      end
    end
  end

end

EasyJob::Behavior.define 'RedmineEnv' do

  on_create do
    @current_user = User.current
    @current_locale = I18n.locale
  end

  on_create do |task|
    begin
      orig_user = User.current
      orig_locale = I18n.locale
      User.current = @current_user
      I18n.locale = @current_locale
      super
    ensure
      User.current = orig_user
      I18n.locale = orig_locale
    end
  end

end
