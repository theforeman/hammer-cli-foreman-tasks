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

    class SkipCommand < HammerCLIForeman::Command
      action :skip
      command_name 'skip'
      desc "Skip plan's actions which are in error state"

      build_options

      success_message _("Task's paused actions skipped")
      failure_message _("Failed to skip some of the actions")
    end

    class ResumeCommand < HammerCLIForeman::Command
      action :resume
      command_name 'resume'
      desc 'Resume paused task'

      build_options

      success_message _("Task resumed")
      failure_message _("Failed to resume task")
    end
      
    class ListCommand < HammerCLIForeman::ListCommand
      
      action :index

      command_name 'list'
      desc 'List tasks'
      @states = ['pending', 'planning', 'planned', 'running', 'paused', 'stopped']
      output ListCommand.output_definition do
        field :id, _("ID")
        field :label, _("Label")
        field :username, _("User")
        field :started_at, _("Started at"), Fields::Date
        field :ended_at, _("Ended at"), Fields::Date
        field :state, _("State")
        field :result, _("Result")
      end

      option '--states', 'STATES', "List of states to show", :format => HammerCLI::Options::Normalizers::EnumList.new(@states)

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
