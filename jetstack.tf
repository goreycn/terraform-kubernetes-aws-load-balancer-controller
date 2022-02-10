module "jetstack_certmanager" {
  count = var.install_certmanager ? 1 : 0
  source = "github.com/bailey84j/terraform-kubernetes-jetstack-certmanager?ref=v1.0.2"
}