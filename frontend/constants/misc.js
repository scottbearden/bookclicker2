const marketplaceFieldsWithClass = {
  "adopted_pen_name": "", 
  "author_profile_link_if_verified": "narrow",
  "active_member_count_delimited": "", 
  "Platform": "desktop", 
  "open_rate": "", 
  "click_rate": "desktop", 
  "solo_price": "not-phone", 
  "feature_price": "not-phone", 
  "mention_price": "not-phone"
}

const marketplaceFields = Object.keys(marketplaceFieldsWithClass);


const marketplaceTableHeaderValues = {
  "adopted_pen_name": "List Name",
  "author_profile_link_if_verified": "",
  "active_member_count_delimited": "List Size",
  "Platform": "Platform",
  "open_rate": "Open Rate",
  "click_rate": "Click Rate",
  "solo_price": "Solo",
  "feature_price": "Feature",
  "mention_price": "Mention" }


export {
  marketplaceFieldsWithClass, marketplaceFields, marketplaceTableHeaderValues
}
  