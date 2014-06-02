module HammerCLIForemanTasks
  class DynflowBinding	

    def initialize(viewer = false)
      foreman_settings = HammerCLI::Settings.get(:foreman)
      host = foreman_settings.fetch(:host).gsub(/\/$/,'')
      provider = viewer ? 'viewer' : 'dynflow'
      @resource = RestClient::Resource.new("#{host}/foreman_tasks/#{provider}/api/execution_plans",
                                           :user => foreman_settings.fetch(:username),
                                           :password => foreman_settings.fetch(:password))
    end
    
    def get_execution_plan(plan_id)
      @resource[plan_id].get
    end
    
    def get_plan_ids(options = {}) 
      @resource.post(options)
    end
    
    def get_action(plan_id, action_id)
      @resource["#{plan_id}/actions/#{action_id}"].get
    end
    
    def upload(hash)
      @resource["add"].post hash
    end
  end
end
