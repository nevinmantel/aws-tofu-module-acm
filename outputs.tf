# ARNs for automatically validated certificates
output "certificate_arns" {
  description = "ARNs of ACM certificates validated with Route53 DNS"
  value = {
    for k, v in aws_acm_certificate_validation.this :
    k => v.certificate_arn
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