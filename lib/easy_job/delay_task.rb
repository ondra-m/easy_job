class EasyJob::DelayTaskProxy < BasicObject

  def initialize(object)
    @object = object
    @chains = []
  end

  def __object
    @object
  end

  def __chains
    @chains
  end

  def easy_delay
    self
  end

  def method_missing(name, *args, &block)
    @chains << [name, args, block]
    if @chains.size == 1
      ::EasyJob::DelayTask.perform_in(1, self)
    end
    self
  end

end

##
# EasyJob::DelayTask
#
# Run chains of commands deleyed
#
#   Issue.first.easy_delay.reschedule_on(Date.today)
#
class EasyJob::DelayTask < EasyJob::RedmineTask

  def perform(proxy)
    object = proxy.__object
    chains = proxy.__chains

    chains.each do |name, args, block|
      object = object.send(name, *args, &block)
    end
  end

end
