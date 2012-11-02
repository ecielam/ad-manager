class AddAutoincludesToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :include_clips, :boolean
    add_column :campaigns, :include_only_clips, :boolean
  end
end
