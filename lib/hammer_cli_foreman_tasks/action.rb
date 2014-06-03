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
        @dynflow_binding = DynflowBinding.new(option_viewer)
        plan_id = option_exec_plan_id.nil? ? task_to_plan_id(option_task_id) : option_exec_plan_id
        plan_id.nil? && exit(HammerCLI::EX_NOT_FOUND)
        path = File.expand_path(option_dir.gsub(/\/$/,''))
        export_actions(plan_id, option_action_id, path)
        HammerCLI::EX_OK
      end

      def export_actions(plan_id, action_ids, path)
        Dir.mktmpdir do |tmp|
          Dir.chdir(tmp)
          FileUtils.mkdir(plan_id) unless Dir.exists?(plan_id)
          action_ids.each do |action_id|
            ActionExportCommand.dump_action(plan_id, action_id)
          end
          FileUtils.mkdir_p(path) unless File.exists?(path)
          FileUtils.cp_r(plan_id, path)
        end
      end

      def self.dump_action(plan_id, action_id)
        begin
          File.write("#{plan_id}/action-#{action_id}.json",
                     @dynflow_binding.get_action(plan_id, action_id))
        rescue Exception => e
          File.exists?("#{plan_id}/action-#{action_id}.json") && File.delete("#{plan_id}/action-#{action_id}.json")
          raise e unless e.http_code == 404
          err = e.message + " - " + e.response
          @output.print_error err
          logger.error err
        end
      end

    end

    autoload_subcommands

  end
end
