.PHONY: apply-prod apply-dev destroy-prod destroy-dev

# TODO: Handle case if 'terraform' is not installed

init:
	@terraform workspace new production 2> /dev/null && echo "Created 'Production'" || true
	@terraform workspace new develop 2> /dev/null && echo "Created 'Development'" || true

status:
	@terraform workspace show

prod: init
	terraform workspace select production

dev: init
	terraform workspace select develop

init-prod: prod
	terraform init -var-file=production.tfvars

init-dev: dev
	terraform init -auto-approve -var-file=develop.tfvars

apply-prod: prod
	terraform apply -var-file=production.tfvars

apply-dev: dev
	terraform apply -auto-approve -var-file=develop.tfvars

destroy-prod: prod
	terraform destroy -var-file=production.tfvars

destroy-dev: dev
	-terraform destroy -auto-approve -var-file=develop.tfvars

redeploy-dev:
	terraform destroy -auto-approve -var-file=develop.tfvars || terraform destroy -auto-approve -var-file=develop.tfvars
	terraform apply -auto-approve -var-file=develop.tfvars