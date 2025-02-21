# Set up GitHub

The GitHub workflows in this project require several secrets set at the repository level or at the environment level.

---

## Workflow Definitions

- **[1-infra-build-deploy-all](./workflows/1-infra-build-deploy-all.yml):** Deploys the main.bicep template then builds and deploys all the apps
- **[2a_deploy_infra.yml](./workflows/1_deploy_infra.yml):** Deploys the main.bicep template with all new resources and does nothing else. You can use this to do a `what-if` deployment to see what resources will be created/updated/deleted by the [main.bicep](../infra/bicep/main.bicep) file.
- **[2b-build-deploy-all.yml](./workflows/2b-build-deploy-all.yml):** Builds the app and deploys it to Azure - this could/should be set up to happen automatically after each check-in to main branch app folder
- **[2c-build-deploy-one.yml](./workflows/2b-build-deploy-all.yml):** Builds the one single app and deploys it to Azure
- **[3_scan_build_pr.yml](./workflows/3_scan_build_pr.yml):** Runs each time a Pull Request is submitted and includes the results in the PR
- **[4_scheduled_scan.yml](./workflows/4_scheduled_scan.yml):** Runs a scheduled periodic scan of the app for security vulnerabilities

---

## Quick Start Summary

This is the short version - see the text below for more details on each of these steps.

1. Set up a federated App Registration configuration for smart-flow-public and for smart-flow-ui repos with your environment name.  

    [https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation-create-trust](https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation-create-trust)

1. Customize these commands:

    ```bash
    gh secret set --env <envName> AZURE_SUBSCRIPTION_ID -b xxx-xx-xx-xx-xxxx
    gh secret set --env <envName> AZURE_TENANT_ID -b xxx-xx-xx-xx-xxxx
    gh secret set --env <envName> CICD_CLIENT_ID -b xxx-xx-xx-xx-xxxx
    gh variable set --env <envName> APP_NAME -b YOUR-APP-NAME-smartflow
    gh variable set --env <envName> APP_NAME_NO_DASHES -b YOURAPPNAMEsmartflow
    gh variable set --env <envName> RESOURCEGROUP_PREFIX -b rg-smartflow
    gh variable set --env <envName> ESOURCEGROUP_LOCATION -b eastus2
    gh variable set --env <envName> OPENAI_DEPLOY_LOCATION -b eastus2
    ```

1. Clone the smart-flow-public repo, then go to that folder and run these commands
1. Clone the smart-flow-ui repo, then go to that folder and run these commands
1. Run the **[1-infra-build-deploy-all](./workflows/1-infra-build-deploy-all.yml) action in the Smart-Flow-Public repo to deploy the API.
1. Run the **1-infra-build-deploy-all** action in the Smart-Flow-UI repo to deploy the UI.

---

## GitHub Secrets and Variables

If you require different credentials for your DEV/QA/PROD environments, you should set up the secrets and variables at the Environment level instead of the Repository level.

### Azure Credentials

You will need to set up the Azure Credentials secrets in the GitHub Secrets at the Repository level before you do anything else.

> Note: These pipelines use a [OpenId Connect connection](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect) to publish resources to Azure.  For more information on how to configure your service principal to use this, see [https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation-create-trust](https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation-create-trust).

**Note:** This service principal must have contributor rights to your subscription (or resource group) to deploy the base resources. To deploy the security roles, it must also have either Owner or User Access Administrator rights.

**Note:** To set the secrets for a specific environment, change the `dev` in the following commands to your environment name:

```bash
gh secret set --env dev AZURE_SUBSCRIPTION_ID -b <yourAzureSubscriptionId>
gh secret set --env dev AZURE_TENANT_ID -b <GUID-Entra-tenant-where-SP-lives>
gh secret set --env dev CICD_CLIENT_ID -b <GUID-application/client-Id>
```

---

### Admin Rights

ADMIN_IP_ADDRESS and ADMIN_PRINCIPAL_ID are optional settings - set only if you want your admin to have access to the Key Vault and Container Registry.
You can customize and run the following commands, or you can set these secrets up manually by going to the Settings -> Secrets -> Actions -> Secrets.

```bash
gh secret set --env dev ADMIN_IP_ADDRESS 192.168.1.1
gh secret set --env dev ADMIN_PRINCIPAL_ID <yourGuid>
```

---

### Resource Configuration Values

These values are used by the Bicep templates to configure the resource names that are deployed. Make sure the App_Name variable is unique to your deploy. It will be used as the basis for the application name and for all the other Azure resources, some of which must be globally unique.

You can customize and run the following commands (or just set it up manually by going to the Settings -> Secrets -> Actions -> Variables).  Replace '<<YOURAPPNAME>>' with a value that is unique to your deployment, which can contain dashes or underscores (i.e. 'xxx-doc-review'). APP_NAME_NO_DASHES should be the same but without dashes.

```bash
gh variable set --env dev APP_NAME -b <<YOUR-APP-NAME>>
gh variable set --env dev APP_NAME_NO_DASHES -b <<YOURAPPNAME>>
gh variable set --env dev RESOURCEGROUP_PREFIX -b rg_ai_docs
gh variable set --env dev RESOURCEGROUP_LOCATION -b eastus2
gh variable set --env dev OPENAI_DEPLOY_LOCATION -b eastus2
```

The Bicep templates will use these values to create the Azure resources. The Resource Group Name will be `<RESOURCEGROUP_PREFIX>-<ENVIRONMENT>` and will be created in the `<RESOURCEGROUP_LOCATION>` Azure region. The `APP_NAME` will be used as the basis for all of the resource names, with the environment name (i.e. dev/qa/prod) appended to each resource name.

The `<OPENAI_DEPLOY_LOCATION>` can be specified if you want to deploy the OpenAI resources in a different region than the rest of the resources due to region constraints.

---


## References

- [Deploying ARM Templates with GitHub Actions](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-github-actions)
- [GitHub Secrets CLI](https://cli.github.com/manual/gh_secret_set)

---

[Home Page](../README.md)
