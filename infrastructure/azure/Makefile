backend_instance_id := moral-eft
instance_id := correct-urchin

login:
	az login
	az account set --subscription "Jim Counts (Personal)"
	az account show --output table

backend_config:
	az keyvault secret download \
		--name azurerm-backend-tfvars \
		--vault-name kv-$(backend_instance_id) \
		--file azurerm.backend.tfvars

init:
	terraform init --upgrade -backend-config azurerm.backend.tfvars
	terraform -v
	terraform providers

config:
	@echo 'resource_group_name="rg-$(instance_id)"' > terraform.auto.tfvars

clean: init config
	terraform destroy -auto-approve