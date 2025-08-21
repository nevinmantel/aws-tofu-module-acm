# ARNs for automatically validated certificates
output "pending_validation_records" {
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

⚠️ IMPORTANT: Add these CNAME records to your DNS provider within 72 hours 
or the ACM certificate request will fail.
EOT

  value = {
    for cert_key, cert in aws_acm_certificate.this :
    cert_key => {
      for opt in cert.domain_validation_options :
      opt.resource_record_name => opt.resource_record_value
    }
    if var.certs[cert_key].validation_method == "manual"
  }
}

# DNS records that Terraform actually created in Route53
output "automatic_dns_validation_records" {
  description = "DNS validation records automatically created in Route53"
  value = {
    for k, r in aws_route53_record.validation :
    k => { "${r.name}" = tolist(r.records)[0] }
  }
}