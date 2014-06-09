module HammerCLIForemanTasks
  class Action < HammerCLIForeman::Command

    class ActionExportCommand < HammerCLIForeman::Command

      include HammerCLIForemanTasks::Helper

      command_name 'export'

      option ['-t', '--task-id'], 'TASK_ID', "ID of task to export"
      option ['-e', '--exec-plan-id'], 'PLAN_ID', "ID of plan to export"
      option '--action-id', 'ACTION_ID', "ID of action to export",
             :required => true,
             :format => HammerCLI::Options::Normalizers::List.new
      option ["-d", "--dir"], "DIR", "Output to DIR", :default => '.'
      option "--viewer", :flag, "Use viewer instead of regular Dynflow"

      validate_options do
        any(:option_task_id, :option_exec_plan_id).required
        all(:option_task_id, :option_exec_plan_id).exist? && all(:option_task_id, :option_exec_plan_id).rejected
      end

      def execute
        @dynflow_binding = DynflowBinding.new(option_viewer?)
        exporter = Exporter.new(logger, @dynflow_binding)
        plan_id = option_exec_plan_id || task_to_plan_id(option_task_id)
        plan_id.nil? && exit(HammerCLI::EX_NOT_FOUND)
        path = File.expand_path(option_dir.gsub(/\/$/,''))
        exporter.export_actions(plan_id, option_action_id, path)
        HammerCLI::EX_OK
      end
    end

    autoload_subcommands

  end
end
