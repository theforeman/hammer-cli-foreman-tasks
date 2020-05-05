require 'date'

module HammerCLIForemanTasks
  module CommandExtensions
    class RecurringLogic < HammerCLI::CommandExtensions
      before_print do |data|
        data['action'] = format_task_input(data['tasks'].last)
        data['last_occurrence'] = recurring_logic_last_occurrence(data)
        data['next_occurrence'] = recurring_logic_next_occurrence(data)
        data['iteration_limit'] = format_recurring_logic_limit(data['max_iteration'])
        data['repeat_until'] = format_recurring_logic_limit(data['end_time'])
      end

      output do |definition|
        definition.insert(:after, :cron_line) do
          field :action, _('Action')
          field :last_occurrence, _('Last occurrence')
          field :next_occurrence, _('Next occurrence')
        end
        definition.insert(:after, :iteration) do
          field :iteration_limit, _('Iteration limit')
        end
        definition.insert(:replace, :end_time) do
          field :repeat_until, _('Repeat until')
        end
      end

      def self.recurring_logic_last_occurrence(recurring_logic)
        last_task = recurring_logic['tasks'].select { |t| t['started_at'] }
                                            .max { |a, b| a['started_at'] <=> b['started_at'] }
        return '-' if last_task.nil? || last_task['started_at'].nil?

        last_task['started_at']
      end

      def self.recurring_logic_next_occurrence(recurring_logic)
        default = '-'
        return default if %w[cancelled finished disabled].include?(recurring_logic['state'])

        last_task = recurring_logic['tasks'].max { |a, b| a['start_at'] <=> b['start_at'] }
        last_task ? last_task['start_at'] : default
      end

      def self.format_task_input(task)
        return '-' unless task

        task['action']
      end

      def self.format_recurring_logic_limit(thing)
        thing || _('Unlimited')
      end
    end
  end
end
