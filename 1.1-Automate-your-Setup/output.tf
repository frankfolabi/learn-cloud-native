output "public_ip" {
  value       = aws_instance.lab.public_ip
  description = "The public IP of the Lab VM"
}

output "private_key_pem" {
  value     = tls_private_key.lab_key_pair.private_key_pem
  sensitive = true
}