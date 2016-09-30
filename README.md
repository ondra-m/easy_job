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

```ruby

```

## Next version

Behaviour model.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ondra-m/easy_job.
