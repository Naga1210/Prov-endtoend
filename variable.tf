variable "Net_work" {
  type = object({
    vpccidr = string
    vpcname = string
    pubsub_info = list(object({
      pubsubcidr = list(string)
      pubsubaz = list(string)
      pubsubname = list(string)
    }))
  })
  default = {
    vpccidr = "10.0.0.0/16"
    vpcname = "mynwvpc"
    pubsub_info = [ {
      pubsubcidr = ["10.0.0.0/24", "10.0.1.0/24"]
      pubsubaz = ["ap-south-1a", "ap-south-1b"]
      pubsubname = ["app", "web"]
    } ]
    
  }
}
