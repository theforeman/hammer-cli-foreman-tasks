module HammerCLIForemanTasks
  class Viewer < HammerCLIForeman::Command

    resource :foreman_tasks_viewer

    class StatusCommand < HammerCLIForeman::Command

      command_name 'status'
      desc 'Show status of the viewer'
      
      action :show
      
      output HammerCLIForeman::InfoCommand.output_definition do
        field :required, _("Required"), Fields::Boolean
        field :initialized, _("Initialized"), Fields::Boolean
        field :started_at, _("Started at"), Fields::Date
        field :plan_count, _("Plan count")
      end

      build_options
    end

    class DropCommand < HammerCLIForeman::DeleteCommand
      
      command_name 'drop'
      desc 'Drop all tasks from viewer'

      build_options      

    end
    
    class AddCommand < HammerCLIForeman::Command
      
      include HammerCLIForemanTasks::Helper

      command_name 'add'
      desc 'Add exported tasks to viewer'

      option ['-f', '--file'], "FILE", "Archive(s) to add to viewer",
      :format => HammerCLI::Options::Normalizers::List.new,
      :required => true

      def execute
        @dynflow_binding = DynflowBinding.new(true)
        option_file.each { |file| upload(file) }
        HammerCLI::EX_OK
      end

      def upload(file)
        begin
          @dynflow_binding.upload(load_archive(file))
        rescue Exception => e
          raise e unless e.http_code == 406
          err = e.message + " - " + e.response
          @output.print_error err
          logger.error err
        end
      end      

      def load_archive(file)
        {
          :upload => File.new(file, 'rb')
        }
      end
    end

    autoload_subcommands

  end
end
