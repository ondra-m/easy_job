class TestTask < EasyJob::Task

  def perform(wait, action)
    sleep wait
    action.call
  end

  def handle_error(ex)

  end

end
