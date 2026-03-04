# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

CREATE OR REPLACE TABLE `{bq_dataset}_bq.summaryassets` AS (
SELECT
  AGA.account_id,
  AGA.account_name,
  AGA.asset_group_id,
  AGA.asset_group_name,
  AGA.campaign_name,
  AGA.campaign_id,
  AGA.asset_id,
  AGA.asset_sub_type,
  'LEARNING' AS asset_performance,
  AGA.text_asset_text,
  AGS.asset_group_status,
  COALESCE(AGA.image_url,CONCAT('https://www.youtube.com/watch?v=',AGA.video_id)) AS image_video,
  COALESCE(AGA.image_url,CONCAT('https://i.ytimg.com/vi/', CONCAT(AGA.video_id, '/hqdefault.jpg'))) AS image_video_url,
  OCID.ocid,
  PARSE_DATE('%Y-%m-%d', AP.date) AS date,
  AP.network,
  COALESCE(AP.clicks, 0) AS clicks,
  COALESCE(AP.impressions, 0) AS impressions,
  COALESCE(AP.cost_micros, 0) AS cost_micros,
  ROUND(COALESCE(AP.cost_micros, 0) / 1e6, 2) AS cost,
  COALESCE(AP.conversions, 0) AS conversions,
  COALESCE(AP.conversions_value, 0) AS conversions_value,
  COALESCE(AP.all_conversions, 0) AS all_conversions,
  COALESCE(AP.all_conversions_value, 0) AS all_conversions_value
FROM `{bq_dataset}.assetgroupasset` AS AGA
JOIN `{bq_dataset}.assetgroupsummary` AS AGS
  USING(asset_group_id)
LEFT JOIN `{bq_dataset}.ocid_mapping` AS OCID
  ON OCID.customer_id = AGA.account_id
LEFT JOIN (
  SELECT
    asset_id,
    asset_group_id,
    campaign_id,
    network,
    date,
    SUM(clicks) AS clicks,
    SUM(impressions) AS impressions,
    SUM(cost) AS cost_micros,
    SUM(conversions) AS conversions,
    SUM(conversions_value) AS conversions_value,
    SUM(all_conversions) AS all_conversions,
    SUM(all_conversions_value) AS all_conversions_value
  FROM `{bq_dataset}.asset_performance`
  GROUP BY asset_id, asset_group_id, campaign_id, network, date
    ) AS AP ON AGA.asset_id = AP.asset_id AND AGA.asset_group_id = AP.asset_group_id AND AGA.campaign_id = AP.campaign_id
WHERE AGA.campaign_id
    IN (SELECT campaign_id FROM `{bq_dataset}.campaign_settings`)
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24);
