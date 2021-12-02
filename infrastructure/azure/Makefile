default: all

CONFIG := terraform.auto.tfvars

env_instance_id     := maximum-walleye
env_subscription_id := 77fc5cff-a120-47a1-83bc-5c64163f872d
ops_instance_id     := immortal-cougar
ops_subscription_id := 17fe8838-4661-4395-bdab-4136639668d9

login:
	az login --use-device-code
	az account set --subscription "Jim Counts (Personal)"
	az account show --output table

azurerm.backend.tfvars:
	az keyvault secret download \
		--name azurerm-backend-tfvars \
		--vault-name kv-$(ops_instance_id) \
		--file azurerm.backend.tfvars

init: azurerm.backend.tfvars
	terraform init --upgrade -backend-config azurerm.backend.tfvars
	terraform -v
	terraform providers

$(CONFIG): variables.tf
	@echo 'resource_group_name="rg-$(env_instance_id)"'   > $(CONFIG)
	@echo 'env_subscription_id="$(env_subscription_id)"' >> $(CONFIG)
	terraform fmt

fmt:
	terraform fmt -recursive

validate:
	terraform validate

plan: $(CONFIG) fmt validate
	terraform plan -out plan.tfplan

apply:
	terraform apply plan.tfplan
	rm plan.tfplan

clean: $(CONFIG) init
	terraform destroy -auto-approve
	rm azurerm.backend.tfvars
	rm $(CONFIG)

all: init plan