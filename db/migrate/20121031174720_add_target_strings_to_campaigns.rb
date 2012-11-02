class AddTargetStringsToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :target_string, :string
  end
end
