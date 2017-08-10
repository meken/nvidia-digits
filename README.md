# Running DIGITS on Azure

This repository provides a sample ARM template for running [NVIDIA DIGITS](https://developer.nvidia.com/digits) on Azure using [nvidia-docker](https://github.com/NVIDIA/nvidia-docker). During the installation MNIST data is downloaded into the /data/mnist directory within the container that runs the DIGITS server. In order to play with this data please follow the instructions on [Getting Started](https://github.com/NVIDIA/DIGITS/blob/master/docs/GettingStarted.md). Please note that the DIGITS server will be listening on port 80 with this setup (mapping the container port 5000 to port 80 on the VM).

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmeken%2Fnvidia-digits%2Fmaster%2Fazure-digits.json)
[![Visualize](http://armviz.io/visualizebutton.png)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fmeken%2Fnvidia-digits%2Fmaster%2Fazure-digits.json)

> Please note that NC-series (GPU enabled instances) are not available in all
> regions, the location parameter reflects that by allowing only the regions
> where these instances are available. 

### Deploying from the cloudshell

A sample ```deploy.sh``` file is provided to run the template from the cloudshell with the new Azure CLI. 
```bash
git clone https://github.com/meken/nvidia-docker.git
cd nvidia-docker
./deploy.sh azure-digits.json
```

If you don't provide the resource group name and location when you run ```deploy.sh```, you'll be prompted for that. You'll be prompted for the template parameters as well (VM size, admin user name, public key etc.)
