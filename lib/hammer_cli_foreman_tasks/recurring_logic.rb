module HammerCLIForemanTasks
  class RecurringLogic < HammerCLIForeman::Command
    resource :recurring_logics

    class ListCommand < HammerCLIForeman::ListCommand
      output do
        field :id, _('ID')
        field :cron_line, _('Cron line')
        field :end_time, _('End time')
        field :iteration, _('Iteration')
        field :state, _('State')
      end

      build_options
    end

    class InfoCommand < HammerCLIForeman::InfoCommand
      output ListCommand.output_definition
      build_options
    end

    class CancelCommand < HammerCLIForeman::DeleteCommand
      action :cancel
      command_name 'cancel'
      success_message _('Recurring logic cancelled.')
      failure_message _('Could not cancel the recurring logic')
      build_options
    end

    autoload_subcommands
  end

  HammerCLI::MainCommand.subcommand 'recurring-logic', _('Recurring logic related actions'), RecurringLogic
end
