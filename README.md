# Getting Started

## Fresh project

1. Decide on a `<PROJECTNAME>`. For DS projects this is the "project ID" on the scoping doc and should wording of the project name in Jira.
1. Press the green `Use This Template` button [above](https://github.com/WarbyParker/warby-ds-template-R/) to make a new repo with just these files (not the history). Settings: Warby Parker organization and Private
1. Go into the new repo's Settings and add Data Science team
1. Go to Manage Topics and add data-science as a topic
1. Use `git clone` to clone the repo locally and you're good to go!

Download [Docker](https://www.docker.com) for your device. Should work on Mac, Linux or Windows. Docker allows you to create lightweight virtual machines, so whatever your computer is running under the hood it can run a little Linux installation with all of the prerequisites installed and without much if any slowdown.

Once this project is configured, you'll be able to stand up or shut down the virtual machine whenever you'd like. You'll edit files locally, but run commands on the virtual machine.

## Running
### Configuring AWS credentials

* Follow the instructions in the [wiki](https://confluence.warbyparker.com/pages/viewpage.action?pageId=72783125) to set up 2-factor authentication for your AWS account
* Make sure you have the AWS CLI client and [aws-mfa](https://github.com/WarbyParker/aws-mfa) installed locally
* run `aws-mfa` to refresh your AWS credentials
* run `$(aws ecr get-login --no-include-email)` to log into Elastic Container Registry. This will allow you to pull our base Docker image.

### Configuring Docker

* Open docker-compose.yaml. Change PROJECTNAME-CHANGEME to the name of the project.
* The base image comes with commonly used dependencies, including:
    * The tidyverse packages
    * RStudio
    * Warbler
    * Stan/RStanARM/BRMS
    * Prophet
    * DVC

* You can edit the Dockerfile to add more R, Linux, or Python dependencies in the appropriate spots.

### Connecting to RStudio

* If you're on a Mac, set your memory limits in Docker to at least 8GB. Apps inside your container will crash if they exceed this memory limit.
  * Click the whale in your menu bar, preferences, advanced, and there you can set the memory limit
* Build and run the container with `docker-compose up -d --build`. This will build and run it in the background.
* `docker-compose` automatically creates a link between this directory and the `/project` directory within the container.
    * Edit files locally on your machine in whatever way you would like, and those files will be automatically synced with the `/project` directory.
* Connect in your browser to `localhost:8787` for RStudio. 
    * The username is `rstudio` and the password is `warbyparker`.
    * If you are in a position where you want multiple R servers running at once, you can edit the port mapping in the `docker-compose.yaml` file. Or let Max know and he'll update the default Docker files to handle more complicated situations like this. Agile!
* Run `docker ps` to see the name of the running container, which should be based on the project name you put in earlier. It's the last column.
* Connect to the running container with `docker exec -it <CONTAINER> /bin/bash` to run a repl or execute dvc tasks. Do your git work on your local machine if possible.
* Kill the container with `docker kill <CONTAINER>`.

### Using DVC
For instructions on using DVC to make your workflow and data reproducible, read the [DVC overview](https://docs.google.com/document/d/1bPO2PcwedGerCWvNeDFPkD6JzId9Dpf7eB_OxoWljBg/edit?usp=sharing).

### Creating a package

Once you're comfortable in R, good practice is to create a package for your functions, and to put your "main" scripts into the top level of the repository. For more information on R packages, see the eBook [R packges](http://r-pkgs.had.co.nz/) by Hadley Wickham. The first few chapters are a fast read and give a good sense for how packages enable you to segment your code.

### Advanced: Spinning up on EC2

* To run the container on a remote machine, first set it up using `docker-machine`
  * To create an x1e.xlarge ($0.80/hr and 120 GB of RAM) use e.g. `docker-machine create --driver amazonec2 --amazonec2-security-group sg_datascience_docker --amazonec2-vpc-id vpc-af8e8dca --amazonec2-ami ami-d15a75c7 --amazonec2-zone "c" --amazonec2-instance-type x1e.xlarge --amazonec2-use-private-address --amazonec2-subnet-id subnet-1766114e <MACHINE NAME>`

* Once the machine is up, call `eval $(docker-machine env <MACHINE NAME>)` to set this new machine to be your target for `docker` commands
  * Call `docker-compose up --build` as normal
  * Call `docker ps` and `docker exec -it <CONTAINER> /bin/bash` to connect as normal
  * Bi-directional mounts between the container and the local machine are trickier to set up. If it's not too big of a lift, use `docker cp local-file-or-dir <CONTAINER>:/project`. Good reason for us to consider moving to s3 files for intermediates. Use `docker commit` to save these intermediate files and things to avoid having to re-upload. Not a great fix but will do for now.
  * Call `docker-machine ssh <MACHINE NAME>` to access the underlying machine directly
  * Ports on that machine should be accessible through our subnet, so e.g. if the ip address is 172.1.1.1, you should be able to hit http://172.1.1.1:8787 to access the web port on the container. UNTIL WE GET HTTPS WORKING, INSTEAD USE AN SSH TUNNEL: `docker-machine ssh <MACHINE NAME> -f -N -L 8787:localhost:8787`

Don't forget to `docker-machine stop <MACHINE NAME>` when you're not using it and `docker-machine rm <MACHINE NAME>` when you're done with it totally

#### EC2 workflow

* Consider everything running on the EC2 instance to be ephemeral. Edit files locally, and copy them up with `docker cp <file> <CONTAINER>:/path/to/file`. Copy down results with `docker cp <CONTAINER>:/path/to/result data/` or wherever you'd like to copy the file.
  * In practice, `docker-machine stop <MACHINE NAME>` and `docker-machine start <MACHINE NAME>` don't destroy the storage, but don't count on being able to use that machine indefinitely. Better to develop locally and copy files up.
* Because of how the container is built, when it's built on the remote box it won't have your source code copied in. You can copy it in using `docker cp` for now, and we'll figure out a better approach in the future.

### Automate build and deploy to AWS ECR

* To automate the process of building your Docker image and retaining it in cloud storage (using Amazon Elastic Container Registry):
  *Copy Makefile and replace `<image_name>` with a unique name for your image. Don't use the name of an existing image in ECR if you don't intend to replace it. See existing images in registry at [Amazon ECR](https://console.aws.amazon.com/ecr/).
  * To build image in local environment: `make build`
  * To publish image to ECR: `make publish`
  * To build and publish image: `make`

* To pull an image from ECR to your runtime environment:
  * Authenticate to ECR registry: `$(aws ecr get-login --no-include-email)`
  * Replace <image_name> with the name of your image and run : `docker pull 844647875270.dkr.ecr.us-west-2.amazonaws.com/<image_name>:latest`
