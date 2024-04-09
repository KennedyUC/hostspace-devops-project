## Deployment of Microservices Application  
This project is an end-to-end deployment of microservices application in EKS using ArgoCD, Helm  and GitHub Actions Workflow. The application consists of three python backend services and one ReactJS frontend service.  
  
The deployment steps involve provisioning the infrastructure for the application deployment.  
  
The following tools are used for the application build and deployment:  
- make (for running the project commands in a clean manner)
- skaffold (for building the docker images and pushing them to the container registry)
- docker (engine for building the application container)
- AWS EKS (for orchestrating the application deployment)
- Helm (for deploying the application YAML templates)
- ArgoCD (for deploying the Application Helm Chart)
- Terraform (for provisioning the AWS infrastructures and kubernetes operators) 
  
## Provisioning the Infrastructure
- Install terraform  

- Create IAM user in AWS and grab the credentials for Authentication  

- Install AWS CLI  

- Configure the AWS CLI with the credentials from above
    ```BASH
    aws configure set aws_access_key_id $AWS_ACCESS_KEY
    aws configure set aws_secret_access_key $AWS_SECRET_KEY
    aws configure set default.region $AWS_REGION
    aws configure set default.output json
    ```  

- Create an S3 bucket for terraform backend  
  
- Run terraform init
    ```BASH
    terraform init \
        -reconfigure \
        -backend-config="bucket=$AWS_BUCKET" \
        -backend-config="key=$ENV/terraform.tfstate" \
        -backend-config="region=$AWS_REGION"
    ``` 

    This will enable the backend configuration to be done dynamically.  

- Run terraform plan  
    ```BASH
    terraform plan --var-file=$ENV-infra.tfvars -out=plan.tfdata
    ```

- Run terraform apply  
    ```BASH
    terraform apply plan.tfdata
    ```  

    This will provision all the AWS resources and k8s operators configured in the terraform module.

## Deploying the application  
- Create the directory for the ENV files  
    ```BASH
    mkdir -p .env/$ENV
    touch ".env/$ENV/core.env"
    touch ".env/$ENV/web.env"
    ```  

- Update the ENV files created above (see the examples in `.env` directory)  
  
- Install make  
  
- Install other tools
    ```BASH
    make ENV=$ENV install-utils
    ``` 

    This will install `skaffold` and `yq` tools. `yq` is used for dynamically updating the YAML manifests.

- Setup App Env Files
    ```BASH
    make ENV=$ENV setup-envs
    ```  

- Login to Docker Registry
    ```BASH
    make ENV=$ENV docker-login
    ```  

- Update Skaffold Manifest file  
    ```BASH
    make ENV=$ENV update-skaffold-manifest
    ```  
      
- Skaffold Build and Push
    ```BASH
    make ENV=$ENV VERSION=$VERSION TAG=$IMG_TAG skaffold-build
    ```
    This will build the docker container images for all the microservices and push them to their respective repositories in the docker container registry  
  
- Connect to AWS EKS  
    ```BASH
    make ENV=$ENV set-kubectl-context
    ```  

- Update the App Chart values file  
    ```BASH
    make ENV=$ENV VERSION=$VERSION TAG=$IMG_TAG update-chart-values
    ```  

- Login to ArgoCD UI and connect the GitHub repository to it.

- Deploy Application using ArgoCD Application 
    ```BASH
    make ENV=$ENV deploy-app
    ```