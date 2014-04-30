Hammer CLI Foreman Tasks
========================

Showing of the tasks (results and progress) in the Hammer CLI.

Allows waiting for async task after the task was triggered.

Usage:

```ruby
class MyAsyncCommand < HammerCLIForemanTasks::AsyncCommand
  action "run"
  command_name "run"

  success_message "Task started with id %{id}s"
  failure_message "Could not run the task"

  build_options
end
```

Also, there is `HammerCLIForemanTasks::Helper` with helper methods, if
the `AsyncCommand` class doesn't fit for the case.

The `AsyncCommand` comes with `--async` option so that the command
doesn't wait for the task to finish.

There is a `task` command with `progress` action available, showing the
progress for action based on id.

Usage:

    # wait for task to finish (showing the progress)
    hammer task progress --id 1234-5678-7654-3210
