class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :name
      t.boolean :active
      t.boolean :completed
      t.datetime :start
      t.datetime :stop

      t.timestamps
    end
  end
end
