require "easy_job/version"
require 'monitor'
require 'concurrent'

module EasyJob
  # Your code goes here...
  extend MonitorMixin
  autoload :Task,           'easy_job/task'
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
