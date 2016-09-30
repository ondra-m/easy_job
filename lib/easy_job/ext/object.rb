class Object

  # Be carefull with nested calling. Parameters could be generated some times.
  #
  #   # It's OK
  #   Issue.first.easy_delay.reschedule_on(Date.today)
  #
  #   # This could be a problem
  #   def calc_date
  #     sleep 100
  #     Date.today
  #   end
  #
  #   Issue.easy_delay.first.reschedule_on(calc_date)
  #
  # On second example only `first` method will be executed because Job does not know
  # how many calling be triggered. Small workaround: method is delayed for 1s.
  #
  def easy_delay
    EasyJob::DelayTaskProxy.new(self)
  end

end
