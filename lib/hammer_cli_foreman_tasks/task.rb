module HammerCLIForemanTasks
  class Task < HammerCLIForeman::Command

    class ProgressCommand < HammerCLIForeman::Command

      include HammerCLIForemanTasks::Helper

      resource :foreman_tasks
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

      require 'zlib'
      require 'archive/tar/minitar'

      include HammerCLIForemanTasks::Helper

      command_name 'export'
      desc 'Export tasks and actions'

      option ["-t", "--task-id"], "TASK_ID", "ID(s) of task to export", :format => HammerCLI::Options::Normalizers::List.new, :default => []
      option ["-e", "--exec-plan-id"], "PLAN_ID", "ID(s) of plan to export",  :format => HammerCLI::Options::Normalizers::List.new, :default => []
      option ["-p", "--on-paused"], :flag, "Operate on all paused tasks"
      option ["-c", "--compression"], :flag, "Use gzip compression"
      option ["-d", "--dir"], "DIR", "Output to DIR", :default => './'
      option ["-a", "--on-all"], :flag, "Operate on all tasks"
      option ["-f", "--full"], :flag, "Export task WITH all actions"
      option "--viewer", :flag, "Use viewer instead of regular Dynflow"


      validate_options do
        any(:option_task_id, :option_exec_plan_id, :option_on_paused, :option_on_all).required
      end

      def execute
        @dynflow_binding = DynflowBinding.new(option_viewer?)
        dest = File.expand_path(option_dir)
        plan_ids = load_plan_ids
        exporter = Exporter.new(logger, @dynflow_binding)
        plan_ids.each do |plan_id|
          exporter.export_plan(plan_id,
                               dest,
                               option_full?,
                               option_compression?)
        end
        HammerCLI::EX_OK
      end

      def all_ids
        MultiJson.load(@dynflow_binding.get_plan_ids)
      end

      def paused_ids
        MultiJson.load(@dynflow_binding.get_plan_ids(:filters => {'state' => 'paused'}))
      end

      def load_plan_ids
        return all_ids if option_on_all?
        return paused_ids if option_on_paused?
        plan_ids = option_exec_plan_id + option_task_id.map { |task_id| task_to_plan_id(task_id) }
        plan_ids.uniq.compact
      end

    end

    self.subcommand 'action', "Manipulate task's actions", HammerCLIForemanTasks::Action
    self.subcommand 'viewer', "Work with the viewer", HammerCLIForemanTasks::Viewer

    autoload_subcommands
  end

  HammerCLI::MainCommand.subcommand 'task', "Tasks related actions.", Task
end
