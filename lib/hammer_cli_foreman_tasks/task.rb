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
      option ["-t", "--task-id"], "TASK_ID", "ID of task to export", :format => HammerCLI::Options::Normalizers::List.new
      option ["-e", "--exec-plan-id"], "PLAN_ID", "ID of plan to export",  :format => HammerCLI::Options::Normalizers::List.new
      option ["-p", "--paused"], :flag, "Operate on all paused tasks"
      option ["-c", "--compression"], :flag, "Use gzip compression"
      option ["-d", "--dir"], "DIR", "Output to DIR"
      option ["-a", "--all"], :flag, "Operate on all tasks"
      option ["-f", "--full"], :flag, "Export task WITH all actions"

      validate_options do
        any(:option_task_id, :option_plan_id, :option_paused, :option_all).required
      end

      def execute
        plan_ids = get_all_ids unless @option_all.nil?
        plan_ids = get_all_ids(true) unless @option_paused.nil?
        plan_ids ||= []
        plan_ids << @option_plan_id
        plan_ids << @option_task_id.map { |task_id| task_to_plan_id(task_id) }
        plan_ids.flatten.uniq.compact

        plan_ids.each do |plan_id|
          export_plan(plan_id, @option_dir, ! @option_full.nil?)
        end
        HammerCLI::EX_OK
      end

      def get_all_ids(only_paused = false)
        MultiJson.load(only_paused ? get_paused : get_all)
      end

      def export_plan(plan_id, path, with_action = false)
        Dir.mktmpdir do |tmp|
          Dir.chdir(tmp)
          begin
            dump_plan(plan_id)
          rescue Exception => e
            # TODO ERROR LOG
            return
          end
          dump_plan_actions(plan_js) if with_action
          if @option_compression.nil?
            FileUtils.cp_r(plan_id, path)
          else
            compress(plan_id)
            FileUtils.cp("#{plan_id}.tar.gz", path)
          end
        end
      end

      def dump_plan(plan_id, path = '.')
        dest = "#{path}/#{plan_id}"
        FileUtils.mkdir_p(dest) unless File.exist?(dest)
        plan_js = get_execution_plan(plan_id)
        File.write("#{dest}/plan.json", plan_js)
      end

      def compress(target)
        archive = "#{target}.tar.gz"
        tgz = Zlib::GzipWriter.new(File.open(archive, 'wb'))
        Archive::Tar::Minitar.pack(target, tgz)
      end

      def dump_plan_actions(plan_js)
        plan = MultiJson.load(plan_js, :symbolize_keys => true)
        action_ids = plan['steps'].map { |step| step['action_id'] }
        action_ids.each { |action_id| dump_action(plan_id, action_id) }
      end

    end
	
		self.subcommand 'action', "Manipulate task's actions", HammerCLIForemanTasks::Action

    autoload_subcommands
  end

  HammerCLI::MainCommand.subcommand 'task', "Tasks related actions.", Task
end
