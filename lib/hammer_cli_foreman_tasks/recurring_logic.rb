module HammerCLIForemanTasks
  class RecurringLogic < HammerCLIForeman::Command
    resource :recurring_logics

    class ListCommand < HammerCLIForeman::ListCommand
      output do
        field :id, _('ID')
        field :cron_line, _('Cron line')
        field :iteration, _('Iteration')
        field :end_time, _('End time')
        field :state, _('State')
      end

      build_options
    end

    class InfoCommand < HammerCLIForeman::InfoCommand
      output ListCommand.output_definition
      build_options

      extend_with(HammerCLIForemanTasks::CommandExtensions::RecurringLogic.new)
    end

    class CancelCommand < HammerCLIForeman::DeleteCommand
      action :cancel
      command_name 'cancel'
      success_message _('Recurring logic cancelled.')
      failure_message _('Could not cancel the recurring logic')
      build_options
    end
    
    class DeleteCommand < HammerCLIForeman::DeleteCommand
      action :bulk_destroy

      option '--cancelled', :flag, _("Only delete cancelled recurring logics")
      option '--finished', :flag, _("Only delete finished recurring logics")
      def request_params
        params = super
        raise ArgumentError, "Please specify if you want to remove cancelled or finished recurring logics using --cancelled or --finished." unless (options['option_cancelled'] || options["option_finished"])
        raise ArgumentError, "Please only use one of the arguments at a time." if (options['option_cancelled'] && options["option_finished"])
        cancelled = "state=cancelled" if options["option_cancelled"]
        finished = "state=finished" if options["option_finished"]
        params["search"] = cancelled || finished
        params
      end

      command_name 'delete'
      desc _("Delete all recuring logics filtered by the arguments")
      failure_message _('Could not delete recurring logics')
      output ListCommand.output_definition

      def execute
        response = send_request
        if response.length > 0
          puts _('The following recurring logics deleted:') + "\n"
          print_data(response)
        else
          puts _("No recurring logics deleted.")
        end
        HammerCLI::EX_OK
      end
    end

    autoload_subcommands
  end

  HammerCLI::MainCommand.subcommand 'recurring-logic', _('Recurring logic related actions'), RecurringLogic
end
