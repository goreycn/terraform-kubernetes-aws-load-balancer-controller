# terraform-kubernetes-aws-load-balancer-controller

Terraform module which deploys Jet Stack Cert Manager

[![Lint Status](https://github.com/bailey84j/terraform-kubernetes-aws-load-balancer-controller/actions/workflows/main.yml/badge.svg)](https://github.com/bailey84j/terraform-kubernetes-aws-load-balancer-controller/actions/workflows/main.yml)
[![LICENSE](https://img.shields.io/github/license/bailey84j/terraform-kubernetes-aws-load-balancer-controller)](https://github.com/bailey84j/terraform-kubernetes-aws-load-balancer-controller/blob/master/LICENSE)


## Examples

- [Standard](https://github.com/bailey84j/terraform-kubernetes-aws-load-balancer-controller/tree/master/examples/standard): Deploying jetstack certmanager using the default settings
- [Custom](https://github.com/bailey84j/terraform-kubernetes-aws-load-balancer-controller/tree/master/examples/custom): Customising the deployment to use a different api_group, name and namespace 

## Contributing

Report issues/questions/feature requests via [issues](https://github.com/bailey84j/terraform-kubernetes-aws-load-balancer-controller/issues/new)
Full contributing [guidelines are covered here](https://github.com/bailey84j/terraform-kubernetes-aws-load-balancer-controller/blob/master/.github/CONTRIBUTING.md)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.8 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.6 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_cluster_role.cert_manager_cainjector](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role.cert_manager_controller_approve_cert_manager_io](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role.cert_manager_controller_certificates](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role.cert_manager_controller_certificatesigningrequests](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role.cert_manager_controller_challenges](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role.cert_manager_controller_clusterissuers](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role.cert_manager_controller_ingress_shim](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role.cert_manager_controller_issuers](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role.cert_manager_controller_orders](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role.cert_manager_edit](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role.cert_manager_view](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role.cert_manager_webhook_subjectaccessreviews](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role_binding.cert_manager_cainjector](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_cluster_role_binding.cert_manager_controller_approve_cert_manager_io](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_cluster_role_binding.cert_manager_controller_certificates](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_cluster_role_binding.cert_manager_controller_certificatesigningrequests](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_cluster_role_binding.cert_manager_controller_challenges](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_cluster_role_binding.cert_manager_controller_clusterissuers](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_cluster_role_binding.cert_manager_controller_ingress_shim](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_cluster_role_binding.cert_manager_controller_issuers](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_cluster_role_binding.cert_manager_controller_orders](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_cluster_role_binding.cert_manager_webhook_subjectaccessreviews](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_deployment.cert_manager](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_deployment.cert_manager_cainjector](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_deployment.cert_manager_webhook](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_manifest.crd_certificaterequests_cert_manager_io](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.crd_certificates_cert_manager_io](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.crd_challenges_acme_cert_manager_io](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.crd_clusterissuers_cert_manager_io](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.crd_issuers_cert_manager_io](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.crd_orders_acme_cert_manager_io](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_mutating_webhook_configuration.cert_manager_webhook](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/mutating_webhook_configuration) | resource |
| [kubernetes_namespace.cert_manager](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_role.cert_manager_cainjector_leaderelection](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |
| [kubernetes_role.cert_manager_leaderelection](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |
| [kubernetes_role.cert_manager_webhook_dynamic_serving](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |
| [kubernetes_role_binding.cert_manager_cainjector_leaderelection](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [kubernetes_role_binding.cert_manager_leaderelection](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [kubernetes_role_binding.cert_manager_webhook_dynamic_serving](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [kubernetes_service.cert_manager](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service.cert_manager_webhook](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service_account.cert_manager](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.cert_manager_cainjector](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.cert_manager_webhook](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_validating_webhook_configuration.cert_manager_webhook](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/validating_webhook_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_group"></a> [api\_group](#input\_api\_group) | The name of the API group to create | `string` | `"cert-manager.io"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The kubernetes version the application is being deployed onto | `string` | `"v1.6.1"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the appliation being deployed | `string` | `"cert-manager"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace to deploy the appliation in | `string` | `"cert-manager"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_group"></a> [api\_group](#output\_api\_group) | The Kubernets API Group that has been created |
<!-- END_TF_DOCS -->
