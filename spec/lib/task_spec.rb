require 'spec_helper'

RSpec.describe EasyJob::Task do

  it 'simle task' do
    @test = 0
    TestTask.perform_async(0, proc{ @test = 1 })
    EasyJob.wait_for_all

    expect(@test).to eq(1)
  end

  it 'exception' do
    @test = 0
    TestTask.perform_async(0, proc{ raise; @test = 1 })
    EasyJob.wait_for_all

    expect(@test).to eq(0)
  end

  it 'states' do
    wrapper = TestTask.perform_in(1, proc{ })

    expect(wrapper).to be_instance_of(EasyJob::TaskWrapper)
    expect(wrapper.pending?).to be_truthy
    expect(wrapper.finished?).to be_falsey

    EasyJob.wait_for_all

    expect(wrapper.pending?).to be_falsey
    expect(wrapper.finished?).to be_truthy
  end

end
