# Jellyfin K8s Deployment

This project provides a script and configuration files for deploying Jellyfin, an open-source media server, in a Kubernetes environment. It uses [Kind](https://kind.sigs.k8s.io/) to set up a local Kubernetes cluster if one is not already available.

## Features

- Automated setup of Jellyfin using Kubernetes
- Support for persistent storage
- Local storage configuration
- Metrics integration for monitoring
- Namespace isolation for Jellyfin services

## Prerequisites

Before you begin, ensure you have installed the following:

- **Docker**: [Get Docker](https://docs.docker.com/get-docker/)
- **Kind**: [Get Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- **kubectl**: [Get kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- **envsubst** (part of `gettext`): Install using your package manager (e.g., `apt`, `brew`, etc.)

## Getting Started

1. **Clone this repository:**

   ```bash
   git clone https://github.com/magicalbob/jellyfin-k8s.git
   cd jellyfin-k8s
   ```

2. **Make the installation script executable:**

   ```bash
   chmod +x install-jellyfin.sh
   ```

3. **Run the installation script:**

   ```bash
   ./install-jellyfin.sh
   ```

   This script will check if `kubectl` is available and if a Kubernetes cluster exists. If not, it will create a new Kind cluster called `kind-jellyfin`. It will also install the necessary Kubernetes resources for Jellyfin, including:

   - Persistent Volume Claims for media and configuration data
   - Deployment and Service files for Jellyfin
   - A local storage class

4. **Access Jellyfin:**

   After the deployment is up and running, you can access Jellyfin by executing the following command to set up port forwarding:

   ```bash
   kubectl port-forward service/jellyfin-service -n jellyfin --address 0.0.0.0 8096:8096
   ```

   Open a web browser and navigate to `http://localhost:8096` to access the Jellyfin interface.

## Configuration

- **Persistent Storage**: 
  The project uses local persistent storage configured in `kind-config.yaml`. Make sure to update the `hostPath` entries to match your local filesystem paths for media and configuration data.

- **Jellyfin Configuration**:
  Customizable configurations for Jellyfin can be made in `jellyfin-config/config/system.xml`. Make sure to adjust settings according to your requirements.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Acknowledgments

- [Jellyfin](https://jellyfin.org/)
- [Kubernetes](https://kubernetes.io/)
- [Kind](https://kind.sigs.k8s.io/)
