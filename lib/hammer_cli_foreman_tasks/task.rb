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
      command_name 'export'
			option "--task-id", "ID", "ID of task to export"

      def execute
				print_message(DynflowBinding.new.get_execution_plan(@option_task_id))
        HammerCLI::EX_OK
      end
    end
	
		self.subcommand 'action', "Manipulate task's actions", HammerCLIForemanTasks::Action

    autoload_subcommands
  end

  HammerCLI::MainCommand.subcommand 'task', "Tasks related actions.", Task
end
