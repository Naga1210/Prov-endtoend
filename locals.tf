locals {
  pub_subnets_value = length(var.Net_work.pubsub_info[0].pubsubaz)
}