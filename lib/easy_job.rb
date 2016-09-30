require 'monitor'
require 'concurrent'
require 'securerandom'

require 'pry'

module EasyJob
  extend MonitorMixin

  autoload :Task,           'easy_job/task'
  autoload :RedmineTask,    'easy_job/redmine_task'
  autoload :DelayTask,      'easy_job/delay_task'
  autoload :DelayTaskProxy, 'easy_job/delay_task'
  autoload :MailerTask,     'easy_job/mailer_task'
  autoload :TaskWrapper,    'easy_job/task_wrapper'
  autoload :Logger,         'easy_job/logger'
  autoload :Queue,          'easy_job/queue'
  autoload :Attribute,      'easy_job/attribute'
  autoload :Logging,        'easy_job/logging'

  def self.get_queue(name)
    synchronize do
      @@queues ||= Concurrent::Map.new
      @@queues.fetch_or_store(name) { EasyJob::Queue.new(name) }
    end
  end

  # Block `all_done?` method for `interval` seconds.
  # Method `all_done?` is checking `scheduled_task_count`
  # but `ScheduledTask` is added to executor queue after delay time.
  def self.block_all_done_for(interval)
    synchronize do
      @@block_all_done_until ||= Time.now

      new_time = Time.now + interval.to_f
      if @@block_all_done_until < new_time
        @@block_all_done_until = new_time
      end
    end
  end

  # One time, non-blocking.
  def self.all_done?
    synchronize do
      return true if @@queues.nil?

      @@block_all_done_until ||= Time.now
      if @@block_all_done_until > Time.now
        false
      else
        @@queues.values.map(&:all_done?).all?
      end
    end
  end

  # Blocking passive waiting.
  def self.wait_for_all(wait_delay: 5)
    loop {
      if all_done?
        return
      else
        sleep wait_delay
      end
    }
  end

  def self.logger
    synchronize do
      @@loger ||= Logger.new(Rails.root.join('log', 'easy_jobs.log'))
    end
  end

end

require 'easy_job/version'
require 'easy_job/ext/object'
require 'easy_job/rails/message_delivery_patch'
require 'easy_job/concurrent/timer_task'
