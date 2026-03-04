SELECT
  asset_group_asset.asset,
  asset_group_asset.field_type,
  asset_group_asset.status,
  asset_group.id AS asset_group_id,
  asset_group.name AS asset_group_name,
  campaign.id AS campaign_id,
  asset.id AS asset_id,
  asset.type AS asset_type,
  customer.id AS account_id,
  segments.date AS date,
  segments.ad_network_type AS network,
  metrics.clicks AS clicks,
  metrics.impressions AS impressions,
  metrics.cost_micros AS cost,
  metrics.conversions AS conversions,
  metrics.conversions_value AS conversions_value,
  metrics.all_conversions AS all_conversions,
  metrics.all_conversions_value AS all_conversions_value
FROM asset_group_asset
WHERE
  campaign.advertising_channel_type = 'PERFORMANCE_MAX'
  AND campaign.status = 'ENABLED'
  AND asset_group.status = 'ENABLED'
  AND segments.date >= '{start_date}'
  AND segments.date <= '{end_date}'
