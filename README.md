# Terraform and Docker Cluster Management Script

GitHub repository: [YaleeA/web_app](https://github.com/YaleeA/web_app)

This project provides a bash script to manage the setup, deployment, and health status of a cluster using Terraform and Docker. The script supports actions such as installing dependencies, starting the cluster, stopping the cluster, and checking the status of running Docker containers.

## Prerequisites

Before running this script, ensure that you are using a supported Linux distribution like **Ubuntu** and have administrative privileges (`sudo` access).

## 1. Setup Environment and Install Dependencies

To set up the environment and install the necessary dependencies, run the script with the `Install` action. The script will:

- Install Git
- Install Terraform (from the official HashiCorp repository)
- Install Docker (including Docker Compose)
- Clone the required project from GitHub

### Steps:

```bash
./manage_cluster.sh Install
```

**Note**: The script automatically installs the required dependencies, but you can manually verify their installation using:

```bash
git --version
terraform --version
docker --version
```

## 2. Running Terraform and Shell Script

Once the environment is set up, you can manage your cluster using the following actions:

### a. Start the Cluster

To start the cluster and deploy infrastructure using Terraform, run:

```bash
./manage_cluster.sh Start
```

This action will:

- Navigate to the `terraform` directory.
- Run `terraform init` to initialize the working directory.
- Create and apply the Terraform plan to deploy the infrastructure.

### b. Stop the Cluster

To destroy the infrastructure and stop the cluster, use the `Stop` action:

```bash
./manage_cluster.sh Stop
```

This action will:

- Run `terraform destroy` to tear down the infrastructure.
- Stop and remove the Docker containers created by Terraform.

### c. Check Status of the Cluster's Containers

To check the status of the running Docker containers, use:

```bash
./manage_cluster.sh Status
```

This action will:

- List all currently running Docker containers.
- Show the status (running or other states) of each container.
- Display the health status if a health check is defined for each container.

## 3. Testing Status of Cluster

### a. Testing Endpoints with `curl`

You can test the health of the container by running `curl` commands against the Nginx load balancer.

#### Test Nginx Load Balancer:

Run the following command to check if Nginx is routing traffic properly through the load balancer:

```bash
curl http://localhost:<nginx_port>
```

Replace `<nginx_port>` with the port number defined in your `vars.tf` (e.g., `8080`).

### b. Testing Load Balancer Behavior

Nginx is configured to distribute requests across multiple Flask application instances using a round-robin method. You can test the load balancing behavior by sending multiple requests to the Nginx load balancer endpoint and checking that responses alternate between different Flask containers.

#### Send multiple requests to Nginx:

You can use a loop to send several requests and observe the response:

```bash
for i in {1..5}; do curl http://localhost:<nginx_port>; done
```

You should see alternating responses from the different Flask application instances (e.g., `web_app_1`, `web_app_2`, etc.).

### c. Important Notes

- **Scaling**: You can easily scale the number of Flask application instances by modifying the `web_app_names` list in `vars.tf`. Terraform will automatically handle scaling the cluster when you run `terraform apply`.
  
- **Logs**: Always check the logs of your Nginx and Flask containers if any issues arise. Use `docker logs <container_id>` to see detailed information.