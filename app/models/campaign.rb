require 'csv'
require 'redis'

class Campaign < ActiveRecord::Base
  attr_accessible :active, :completed, :name, :start, :stop, :include_only_clips, :include_clips
  attr_accessible :target_string, :clip_pids, :collection_pids

  after_save :store_pids
  after_create :update_campaign_record

  AdCampaignNamespace = 'Hark:AdCampaign'
  def store_pids
    pidlist = validate_pids

    pidlist.each { |pid|
      Redis.current["#{AdCampaignNamespace}:ActivePids:#{pid.strip}"] = id
    }

    cleanup_campaign
    update_campaign_record
  end

  def update_campaign_record
    Redis.current["#{AdCampaignNamespace}:Campaigns:#{id}:Active"] = active
    Redis.current["#{AdCampaignNamespace}:Campaigns:#{id}:TargetString"] = target_string
    Redis.current["#{AdCampaignNamespace}:Campaigns:#{id}:StartDate"] = start
    Redis.current["#{AdCampaignNamespace}:Campaigns:#{id}:EndDate"] = stop
    Redis.current["#{AdCampaignNamespace}:Campaigns:#{id}:Clips"] = clip_pids
    Redis.current["#{AdCampaignNamespace}:Campaigns:#{id}:Collections"] = collection_pids
    Redis.current["#{AdCampaignNamespace}:Campaigns:#{id}:IncludeAll"] = include_clips
    Redis.current["#{AdCampaignNamespace}:Campaigns:#{id}:IncludeOnly"] = include_only_clips

    Redis.current["#{AdCampaignNamespace}:Campaigns:#{id}:Initialized"] = 1
  end

  def cleanup_campaign
    return unless Redis.current["#{AdCampaignNamespace}:Campaigns:#{id}:Initialized"]
    old_clips = CSV.parse(Redis.current["#{AdCampaignNamespace}:Campaigns:#{id}:Clips"])[0] || []
    old_collections = CSV.parse(Redis.current["#{AdCampaignNamespace}:Campaigns:#{id}:Collections"])[0] || []
    new_clips = CSV.parse(clip_pids)[0] || []
    new_collections = CSV.parse(collection_pids)[0] || []

    pids = (old_clips - new_clips) + (old_collections - new_collections)

    pids.each { |pid| Redis.current.del("#{AdCampaignNamespace}:ActivePids:#{pid.strip}") }
  end

  def validate_pids
    clips = CSV.parse(clip_pids)[0] || []
    collections = CSV.parse(collection_pids)[0] || []

    # Could eventually validate each pid here ... for now we strip extra whitespace from each one
    new_clips = []
    clips.each { |pid| new_clips << pid.strip }
    clip_pids = new_clips.to_csv.strip

    new_coll = []
    unless collections.nil?
      collections.each { |pid| new_coll << pid.strip }
      collection_pids = new_coll.to_csv.strip
    end

    new_clips + new_coll
  end
end
