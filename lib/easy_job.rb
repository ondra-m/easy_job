require 'monitor'
require 'concurrent'
require 'securerandom'

module EasyJob
  extend MonitorMixin
  autoload :Task,           'easy_job/task'
  autoload :TaskWrapper,    'easy_job/task_wrapper'
  def self.get_queue(name)
    synchronize do
      @@queues ||= Concurrent::Map.new
      @@queues.fetch_or_store(name) { EasyJob::Queue.new(name) }
    end
  end

  def self.logger
    synchronize do
      @@loger ||= Logger.new(Rails.root.join('log', 'easy_jobs.log'))
    end
  end
end
require 'easy_job/version'
