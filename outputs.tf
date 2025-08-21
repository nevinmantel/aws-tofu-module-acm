# ARNs for automatically validated certificates
output "certificate_arns" {
  description = "DNS records required to validate ACM certificates. Add these manually or use Route53 for automatic validation later."
  value = {
    for k, v in aws_acm_certificate.this :
    k => tolist(v.domain_validation_options)
  }
}

# DNS records for manual validation
output "manual_dns_validation_records" {
  description = <<EOT
DNS records that must be created manually to validate ACM certificates.

⚠️ IMPORTANT: Add these CNAME records to your DNS provider within 24 hours 
or the ACM certificate request will fail.
EOT

  value = {
    for k, v in aws_acm_certificate.this :
    k => v.domain_validation_options
    if var.certs[k].validation_method == "manual"
  }
}

# DNS records that were auto-created
output "automatic_dns_validation_records" {
  value = {
    for k, v in aws_acm_certificate.this :
    k => v.domain_validation_options
    if var.certs[k].validation_method == "automatic"
  }
}