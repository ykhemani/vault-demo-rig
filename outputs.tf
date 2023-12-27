output "public_ips" {
  value = aws_instance.instance.public_ip
}

output "private_ips" {
  value = aws_instance.instance.private_ip
}

output "connection_strings" {
  value = {
    ssh              = "ssh -i ./ssh_key ubuntu@${aws_instance.instance.public_ip}",
    hosts_file_entry = "${aws_instance.instance.public_ip} vault.${var.domain} mysql.${var.domain} web.demo.${var.domain}"
    vault_url        = "https://vault.${var.domain}:8200/",
    web_url          = "https://web.demo.${var.domain}/",
    php_info_url     = "https://web.demo.${var.domain}/pinfo.php",
    php_db_secure    = "https://web.demo.${var.domain}/db-secure.php"
  }
}
