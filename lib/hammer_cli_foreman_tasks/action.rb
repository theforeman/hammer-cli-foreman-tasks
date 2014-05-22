module HammerCLIForemanTasks
  class Action < HammerCLIForeman::Command

    class ActionExportCommand < HammerCLIForeman::Command

      include HammerCLIForemanTasks::Helper

      command_name 'export'

      option ['-t', '--task-id'], 'task_id', "ID of task to export"
      option ['-e', '--exec-plan-id'], 'plan_id', "ID of plan to export"
      option '--action-id', 'action_id', "ID of action to export",
             :required => true,
             :format => HammerCLI::Options::Normalizers::List.new
      option ["-d", "--dir"], "DIR", "Output to DIR"

      validate_options do
        any(:option_task_id, :option_plan_id).required
        all(:option_task_id, :option_plan_id).exist? && all(:option_task_id, :option_plan_id).rejected
      end

      def execute
        plan_id = @option_plan_id.nil? ? task_to_plan_id(@option_task_id) : @option_plan_id
        path = @option_dir.nil? ? '.' : @option_dir
        path.gsub!(/\/$/,'')
        FileUtils.mkdir_p("#{path}/#{plan_id}") unless File.exists?("#{path}/#{plan_id}")
        export_actions(plan_id, @option_action_id, path)
        HammerCLI::EX_OK
      end

      def export_actions(plan_id, action_ids, path)
        Dir.mktmpdir do |tmp|
          Dir.chdir(tmp)
          FileUtils.mkdir(plan_id) unless Dir.exists?(plan_id)
          action_ids.each do |action_id|
            dump_action(plan_id, action_id)
          end
          FileUtils.cp_r(plan_id, path)
        end
      end

      def dump_action(plan_id, action_id)
        begin
          File.write("#{plan_id}/action-#{action_id}.json",
                     get_action(plan_id, action_id))
        rescue Exception => e
          File.exists?("#{plan_id}/action-#{action_id}.json") && File.delete("#{plan_id}/action-#{action_id}.json")
          # TODO ERROR LOG
        end
      end

    end

    autoload_subcommands

  end
end
