output "mypublicip" {
  value = "http://${aws_instance.myec2[0].public_ip}:80"
}