output keypair_priv {
  description = "SSH private key"
  sensitive   = true
  value       = tls_private_key.private_key.private_key_pem
}
