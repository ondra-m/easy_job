module EasyJob
  class Queue < Concurrent::Synchronization::LockableObject

    attr_reader :pool

    # == ThreadPoolExecutor options:
    # idletime::
    #   The number of seconds that a thread may be idle before being reclaimed
    #
    # auto_terminate::
    #   When true (default) an at_exit handler will be registered which
    #   will stop the thread pool when the application exits
    #
    # max_queue::
    #   0 is unlimited
    #
    DEFAULT_EXECUTOR_OPTIONS = {
        min_threads:    3,
        max_threads:    3,
        idletime:       60,
        max_queue:      0,
        auto_terminate: false
    }

    def initialize(name)
      super()
      @name = name
      @pool = Concurrent::ThreadPoolExecutor.new(DEFAULT_EXECUTOR_OPTIONS)
    end

    def post(*args, &block)
      synchronize {
        @pool.post(*args, &block)
      }
    end

    # It will work only if perform method was wrapped by begin rescue end
    def all_done?
      pool.scheduled_task_count == pool.completed_task_count
    end

  end
end
