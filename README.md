# EasyJob

Asynchronous job for Redmine, EasyRedmine and EasyProject.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'easy_job'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install easy_job

## Usage

### Delay jobs

Every methods called after `.easy_delay` will be delayed and executed on other thread. This method could be used for any ruby Object.

```ruby
# Reschedule first issue to today
Issue.first.easy_delay.reschedule_on(Date.today)

# Save ORM object with lot of callbacks
[Issue.new, Issue.new].map { |i| i.easy_delay.save }
```

### Mailer jobs

Deliver email later.

```ruby
# Generating and sending will be done later
Mailer.issue_add(issue, ['test@example.net'], []).easy_deliver

# Email is generated now but send later
Mailer.issue_add(issue, ['test@example.net'], []).easy_safe_deliver
```

### Custom jobs

You can also create custom task with own exceptions capturing.

Job can be started with 3 calling:

- `.perform_async(*args)` started when pool cointains free worker
- `.perform_in(*args, interval:)` job is added to queue after interval second
- `.perform_every(*args, interval:, timeout:, start_at:)` job is executed every delay second
  - **interval:** seconds between task executions (required)
  - **timeout:** max seconds for running (optional)
  - **start_at:** time of first execution (optional)

```ruby
class PDFJob < EasyJob::RedmineTask

  include IssuesHelper

  def perform(issue_ids, project_id)
    issues = Issue.where(id: issue_ids)
    project = Project.find(project_id)
    query = IssueQuery.new

    result = issues_to_pdf(issues, project, query)

    path = Rails.root.join('public', 'issues.pdf')
    File.open(path, 'wb') {|f| f.write(result) }
  end

end

PDFJob.perform_async(Issue.ids, Project.first.id)
```

### Tenant

If you are using tenant you can simply use

```ruby
require 'easy_job/tenant_wrapper'
```


## Ideas for next version

- Behaviour model.
- Repeat after failing.
- Dashboard.
- Queue defining.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ondra-m/easy_job.
