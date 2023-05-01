output "prometheus_ip" {
  value = module.bastion.instance_ip
}

output "node1_ip" {
  value = module.node1.instance_ip
}