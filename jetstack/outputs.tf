output "api_group" {
  description = "The Kubernets API Group that has been created"
  value       = replace("${kubernetes_manifest.crd_certificaterequests_cert_manager_io.object.metadata.uid}${kubernetes_manifest.crd_certificaterequests_cert_manager_io.object.spec.group}",kubernetes_manifest.crd_certificaterequests_cert_manager_io.object.metadata.uid,"")
}


