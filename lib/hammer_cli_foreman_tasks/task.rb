module HammerCLIForemanTasks
  class Task < HammerCLIForeman::Command

    resource :foreman_tasks

    class ProgressCommand < HammerCLIForeman::Command

      include HammerCLIForemanTasks::Helper

      action :show
      build_options

      command_name "progress"
      desc _("Show the progress of the task")

      def execute
        success = task_progress(option_id)
        success ? HammerCLI::EX_OK : HammerCLI::EX_SOFTWARE
      end

    end

    class ListCommand < HammerCLIForeman::ListCommand
      output do
        field :id, _('ID')
        field :action, _('Name')
        field :username, _('Owner')
        field :started_at, _('Started at'), Fields::Date
        field :ended_at, _('Ended at'), Fields::Date
        field :state, _('State')
        field :result, _('Result')
        from :humanized do
          field :action, _('Task action')
          field :errors, _('Task errors'), Fields::List, :hide_blank => true
        end
      end

      build_options
    end

    class ResumeCommand < HammerCLIForeman::InfoCommand
      action :bulk_resume

      command_name "resume"
      desc _("Resume all tasks paused in error state")

      output do
        field :total, _("Total tasks found paused in error state")

        field :total_resumed, _("Total tasks resumed")
        collection :resumed, _("Resumed tasks") do
          field :id, _("Task identifier")
          from :humanized do
            field :action, _("Task action")
            field :errors, _("Task errors"), Fields::List, :hide_blank => true
          end
        end

        field :total_failed, _("Total tasks failed to resume")
        collection :failed, _("Failed tasks") do
          field :id, _("Task identifier")
          from :humanized do
            field :action, _("Task action")
            field :errors, _("Task errors"), Fields::List, :hide_blank => true
          end
        end

        field :total_skipped, _("Total tasks skipped")
        collection :skipped, _("Skipped tasks") do
          field :id, _("Task identifier")
          from :humanized do
            field :action, _("Task action")
            field :errors, _("Task errors"), Fields::List, :hide_blank => true
          end
        end
      end

      def extend_data(data)
        data["total_resumed"] = data["resumed"].length
        data["total_failed"] = data["failed"].length
        data["total_skipped"] = data["skipped"].length
        data
      end

      build_options
    end

    autoload_subcommands
  end

  HammerCLI::MainCommand.subcommand 'task', "Tasks related actions.", Task
end
