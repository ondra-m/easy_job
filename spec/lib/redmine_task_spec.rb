require 'spec_helper'

class SavingIssue < EasyJob::RedmineTask

  def perform(wait, issues)
    sleep wait
    issues.each(&:save)
  end

end

RSpec.describe EasyJob::RedmineTask do

  before(:each) do
    User.current = User.where(admin: true).first
  end

  let(:project) { Project.first_or_create!(name: 'Project 1', identifier: 'project-1') }

  it 'does something' do
    issues = Array.new(10) { |i|
      Issue.new(subject: 'Issue', project: project, tracker: Tracker.first, author: User.current)
    }
    expect(issues.map(&:persisted?)).to all(be_falsey)

    SavingIssue.perform_async(1, issues)
    expect(issues.map(&:persisted?)).to all(be_falsey)

    EasyJob.wait_for_all
    expect(issues.map(&:persisted?)).to all(be_truthy)
  end

end
