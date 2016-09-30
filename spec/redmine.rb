require 'pathname'
require 'easy_job/task_wrapper'

class User
  def self.current
  end
end

class I18n
  def self.locale
  end
end

module Rails
  def self.root
    Pathname.new(Dir.pwd)
  end
end

module EasyJob
  class TaskWrapper

    def ensure_connection
      yield
    end

    def ensure_redmine_env
      yield
    end

  end
end

