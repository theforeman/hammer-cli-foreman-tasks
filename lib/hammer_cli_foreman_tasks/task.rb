module HammerCLIForemanTasks
  class Task < HammerCLIForeman::Command

    resource :foreman_tasks

    class ProgressCommand < HammerCLIForeman::Command

      include HammerCLIForemanTasks::Helper

      action :show
      build_options

      command_name "progress"
      desc "Show the progress of the task"

      def execute
        task_progress(option_id)
        HammerCLI::EX_OK
      end

    end

    class TaskExportCommand < HammerCLIForeman::Command

      include HammerCLIForemanTasks::Helper

      command_name 'export'
      option "--task-id", "TASK_ID", "ID of task to export"
      option "--plan-id", "PLAN_ID", "ID of plan to export"

      validate_options do
        any(:option_task_id, :option_plan_id).required
        all(:option_task_id, :option_plan_id).exist? && all(:option_task_id, :option_plan_id).rejected
      end

      def execute
        id = @option_plan_id.nil? ? task_to_plan_id(@option_task_id) : @option_plan_id
        print_message(DynflowBinding.new.get_execution_plan(id))
        HammerCLI::EX_OK
      end
    end
	
		self.subcommand 'action', "Manipulate task's actions", HammerCLIForemanTasks::Action

    autoload_subcommands
  end

  HammerCLI::MainCommand.subcommand 'task', "Tasks related actions.", Task
end
