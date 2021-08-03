# run with:
# aws-mfa
# $(aws ecr get-login --no-include-email)
# docker-compose build

# This will always fetch the latest version of the base image,
# which is tied to the master branch of https://github.com/WarbyParker/warbler.
# If you want to freeze your dependencies, you can peg your container to a
# specific Warbler version.
# To do that, change warbler:latest to warbler:<GIT COMMIT HASH>.
# For a complete list of available container versions,
# see https://console.aws.amazon.com/ecs/home?region=us-east-1#/repositories/warbler.
FROM 844647875270.dkr.ecr.us-east-1.amazonaws.com/warbler:latest

# Edit and uncomment the following to install additional Linux packages
# RUN apt-get install -y PACKAGENAME \
#                        OTHERPACKAGENAME

# Edit and uncomment the following to install additional Python packages
# RUN pip install PACKAGENAME \
#                 OTHERPACKAGENAME

# Edit and uncomment the following to install additional R packages
# RUN install2.r --error \
#      --deps TRUE \
#      PACKAGENAME \
#      OTHERPACKAGENAME

# When building on a remote, sometimes you need to add a user
#RUN useradd -ms /bin/bash warby
#USER warby
