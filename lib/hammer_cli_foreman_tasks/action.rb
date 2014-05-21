module HammerCLIForemanTasks
  class Action < HammerCLIForeman::Command

    class ActionExportCommand < HammerCLIForeman::Command

      include HammerCLIForemanTasks::Helper

      command_name 'export'

      option '--task-id', 'task_id', "ID of task to export"
      option '--plan-id', 'plan_id', "ID of plan to export"
      option '--action-id', 'action_id', "ID of action to export", :required => true

      validate_options do
        any(:option_task_id, :option_plan_id).required
        all(:option_task_id, :option_plan_id).exist? && all(:option_task_id, :option_plan_id).rejected
      end

      def execute
        id = @option_plan_id.nil? ? task_to_plan_id(@option_task_id) : @option_plan_id
        print_message(DynflowBinding.new.get_action(id, @option_action_id))
        HammerCLI::EX_OK
      end
    end

    autoload_subcommands

  end
end
