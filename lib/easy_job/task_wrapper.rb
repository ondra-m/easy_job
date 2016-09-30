module EasyJob
  class TaskWrapper
    include Logging

    STATE_PENDING = 0
    STATE_RUNNING = 1
    STATE_FINISHED = 2

    def initialize(task_class, args)
      @task_class = task_class
      @args = args
      @state = STATE_PENDING

      @connection_attempt = 0
      @current_user = User.current
      @current_locale = I18n.locale
    end

    def job_id
      @job && @job.job_id
    end

    def pending?
      @state == STATE_PENDING
    end

    def running?
      @state == STATE_RUNNING
    end

    def finished?
      @state == STATE_FINISHED
    end

    def perform
      @job = @task_class.new
      @job.job_id = SecureRandom.uuid

      ensure_connection {
        ensure_redmine_env {
          begin
            @state = STATE_RUNNING
            @job.perform(*@args)
          rescue => ex
            @job.handle_error(ex)
          ensure
            @state = STATE_FINISHED
            log_info 'Job ended'
          end
        }
      }
    rescue => e
      # Perform method must end successfully.
      # Otherwise `all_done?` end on deadlock.
    end

    def ensure_connection
      ActiveRecord::Base.connection_pool.with_connection { yield }
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

    def ensure_redmine_env
      orig_user = User.current
      orig_locale = I18n.locale
      User.current = @current_user
      I18n.locale = @current_locale
      yield
    ensure
      User.current = orig_user
      I18n.locale = orig_locale
    end

    def inspect
      %{#<EasyJob::TaskWrapper(#{@task_class}) id="#{job_id}">}
    end

  end
end
