class AddPidsToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :clip_pids, :string
    add_column :campaigns, :collection_pids, :string
  end
end
