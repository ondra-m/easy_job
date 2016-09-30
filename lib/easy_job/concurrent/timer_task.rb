module EasyJob
  module TimerTaskPatch

    def execute_after(interval)
      synchronize do
        if @running.true?
          raise 'This method can be used only if task is not running.'
        end

        @running.make_true
        schedule_next_task(interval)
      end
      self
    end

  end
end

Concurrent::TimerTask.prepend(EasyJob::TimerTaskPatch)
