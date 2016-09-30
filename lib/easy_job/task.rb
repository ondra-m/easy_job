module EasyJob
  class Task
    include Attribute
    include Logging

    attribute :queue_name, 'default'

    attr_accessor :job_id
    attr_accessor :job_options

    def self.perform_async(*args)
      wrapper = TaskWrapper.new(self, args)
      queue = EasyJob.get_queue(queue_name)
      queue.post(wrapper, &:perform)
      wrapper
    end

    def self.perform_in(interval, *args)
      wrapper = TaskWrapper.new(self, args)
      queue = EasyJob.get_queue(queue_name)
      concurrent_job = Concurrent::ScheduledTask.execute(interval.to_f, args: wrapper, executor: queue.pool, &:perform)
      EasyJob.block_all_done_for(interval)
      wrapper
    end

    # Perform task on given interval. Return an `Array[TaskWrapper, TimerTask]`.
    #
    # == Parameters:
    # interval::
    #   number of seconds between task executions
    #
    # timeout_interval::
    #   number of seconds a task can run before it is considered to have failed
    #   (default: 9_999)
    #
    # starts_at::
    #   time of first execution
    #   nil is equal to Time.now + interval (default)
    #
    def self.perform_every(*args, interval:, timeout_interval: 9_999, start_at: nil)
      if start_at.is_a?(Time)
        start_at = start_at - Time.now
      end

      if !start_at.is_a?(Numeric) || start_at < 0
        raise ArgumentError, 'Start_at must be a Numeric or Time in future.'
      end

      wrapper = TaskWrapper.new(self, args)

      task = Concurrent::TimerTask.new{|t| wrapper.perform(timer_task: t) }
      task.execution_interval = interval
      task.timeout_interval = timeout_interval
      task.execute_after(start_at)

      [wrapper, task]
    end

    def perform(*)
      raise NotImplementedError
    end

    def handle_error(ex)
      log_error ex.message
      ex.backtrace.each do |line|
        log_error line
      end
    end

  end
end

