module HammerCLIForemanTasks
  class DynflowBinding	
    foreman_settings = HammerCLI::Settings.get(:foreman)
    @resource = RestClient::Resource.new(foreman_settings.fetch(:host).gsub(/\/$/,'')+'/foreman_tasks/dynflow/api/execution_plans',
                                         :user => foreman_settings.fetch(:username),
                                         :password => foreman_settings.fetch(:password))
    
    def self.get_execution_plan(plan_id)
      @resource[plan_id].get
    end
    
    def self.get_all_plans
      @resource.post({})
    end
    
    def self.get_paused_plans
      @resource.post(:filters => {'state' => 'paused'})
    end
    
    def self.get_action(plan_id, action_id)
      @resource["#{plan_id}/actions/#{action_id}"].get
    end
    
    def self.upload(hash)
      @resource["add"].post hash
    end
  end
end
