module CampaignsHelper
  def display_value(s)
    return s unless s.blank?
    "No Value Set"
  end
end
