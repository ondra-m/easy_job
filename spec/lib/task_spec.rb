require 'spec_helper'

class SimpleTask < EasyJob::Task

  def perform(func)
    func.call
  end

  def handle_error(ex)
  end

end

RSpec.describe EasyJob::Task do

  it 'simle task' do
    @test = 0
    SimpleTask.perform_async(proc{ @test = 1 })
    EasyJob.wait_for_all

    expect(@test).to eq(1)
  end

  it 'exception' do
    @test = 0
    SimpleTask.perform_async(proc{ raise; @test = 1 })
    EasyJob.wait_for_all

    expect(@test).to eq(0)
  end

  it 'states' do
    wrapper = SimpleTask.perform_in(1, proc{ })

    expect(wrapper).to be_instance_of(EasyJob::TaskWrapper)
    expect(wrapper.pending?).to be_truthy
    expect(wrapper.finished?).to be_falsey

    EasyJob.wait_for_all

    expect(wrapper.pending?).to be_falsey
    expect(wrapper.finished?).to be_truthy
  end

end
