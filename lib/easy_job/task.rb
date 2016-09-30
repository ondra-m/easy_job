module EasyJob
  class Task
    include Attribute
    include Logging

    attribute :queue_name, 'default'

    attr_accessor :job_id

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

