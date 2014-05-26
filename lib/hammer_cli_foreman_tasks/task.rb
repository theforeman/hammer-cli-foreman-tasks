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
    
    class TaskViewCommand < HammerCLIForeman::Command
      
      command_name 'view'

      option ['-f', '--file'], "FILE", "Archive to add to viewer",
      :format => HammerCLI::Options::Normalizers::List.new,
      :required => true
      
      def execute
        require 'pry'; binding.pry
        option_file.each { |file| DynflowBinding.upload(load_archive(file)) }
        HammerCLI::EX_OK
      end

      def load_archive(file)
        {
          :upload => File.new(file, 'rb')
        }
      end
    end

    class TaskExportCommand < HammerCLIForeman::Command

      require 'zlib'
      require 'archive/tar/minitar'

      include HammerCLIForemanTasks::Helper

      command_name 'export'
      option ["-t", "--task-id"], "TASK_ID", "ID of task to export", :format => HammerCLI::Options::Normalizers::List.new
      option ["-e", "--exec-plan-id"], "PLAN_ID", "ID of plan to export",  :format => HammerCLI::Options::Normalizers::List.new
      option ["-p", "--on-paused"], :flag, "Operate on all paused tasks"
      option ["-c", "--compression"], :flag, "Use gzip compression"
      option ["-d", "--dir"], "DIR", "Output to DIR", :default => './'
      option ["-a", "--on-all"], :flag, "Operate on all tasks"
      option ["-f", "--full"], :flag, "Export task WITH all actions"

      @output = HammerCLI::Output::Output.new

      validate_options do
        any(:option_task_id, :option_exec_plan_id, :option_on_paused, :option_on_all).required
      end

      def execute
        dest = File.expand_path(option_dir)
        plan_ids = load_plan_ids
        plan_ids.each { |plan_id| export_plan(plan_id, dest, option_full?) }
        HammerCLI::EX_OK
      end

      def all_ids
        MultiJson.load(DynflowBinding.get_all_plans)
      end

      def paused_ids
        MultiJson.load(DynflowBinding.get_paused_plans)
      end

      def load_plan_ids
        plan_ids = all_ids if option_on_all?
        plan_ids = paused_ids if option_on_paused?
        plan_ids ||= []
        plan_ids << option_exec_plan_id
        plan_ids << option_task_id.map { |task_id| task_to_plan_id(task_id) } unless option_task_id.nil?
        plan_ids.flatten.uniq.compact
      end
      
      def export_plan(plan_id, path, with_action = false)
        Dir.mktmpdir do |tmp|
          Dir.chdir(tmp)
          plan_js = dump_plan(plan_id)
          dump_plan_actions(plan_js) if with_action
          if option_compression?
            compress(plan_id)
            FileUtils.cp("#{plan_id}.tar.gz", path)
          else
            FileUtils.mkdir_p(path) unless File.exists?(path)
            FileUtils.cp_r(plan_id, path)
          end
        end
      end

      def dump_plan(plan_id)
        FileUtils.mkdir_p(plan_id) unless File.exist?(plan_id)
        begin
          plan_js = DynflowBinding.get_execution_plan(plan_id)
        rescue Exception => e
          raise e unless e.http_code == 404
          err = e.message + " - " + e.response
          @output.print_error err
          logger.error err
        end
        File.write("#{plan_id}/plan.json", plan_js)
        plan_js
      end

      def compress(target)
        archive = "#{target}.tar.gz"
        tgz = Zlib::GzipWriter.new(File.open(archive, 'wb'))
        Archive::Tar::Minitar.pack(target, tgz)
      end

      def dump_plan_actions(plan_js)
        plan = MultiJson.load(plan_js, :symbolize_keys => true)
        action_ids = plan[:steps].map { |step| step[:action_id] }.uniq
        action_ids.each { |action_id| Action::ActionExportCommand.dump_action(plan[:id], action_id) }
      end

    end
    
    self.subcommand 'action', "Manipulate task's actions", HammerCLIForemanTasks::Action

    autoload_subcommands
  end

  HammerCLI::MainCommand.subcommand 'task', "Tasks related actions.", Task
end
