module HammerCLIForemanTasks
  class Action < HammerCLIForeman::Command

    class ActionExportCommand < HammerCLIForeman::Command
      command_name 'export'

      option '--task-id', 'task_id', "ID of task to export", :required => true
      option '--action-id', 'action_id', "ID of action to export", :required => true

      def execute
				print_message(DynflowBinding.new.get_action(@option_task_id, @option_action_id))
        HammerCLI::EX_OK
      end
    end

    autoload_subcommands

  end
end
