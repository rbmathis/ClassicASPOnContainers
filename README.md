# ClassicASPOnContainers
Example multi-layer windows container to show build-up and code deployment.

Intended to be followed step-by-step to demonstrate how containers benefit many different teams and personas in the pipeline.

The dockerfile.simple file is an example of how we can get out of the "gold image" business.  Instead of the pain, time, nuisance of building giant WIMs or VHDs, we can just create a simple file that is used every time to ensure our corp standards are applied.

The dockerfile.buildIIS is an example of what a web admin team would produce, instead of scripting or manually tweaking the various IIS settings on each server that is created.  We can put the steps here inside the dockerfile, and they'll be baked into the resultant container image every time - no additional scripting or work needed.

The dockerfile (no extension) is an example of how to pull classic ASP code from a github repo and install it into the container image. It also demonstrates how to merge secrets (global.asa)into the container image upon docker build.  


# Step-by-step:
1. Open and discuss dockerfile.simple.  It pulls the latest Microsoft IIS image and then has some comments to show where the "image" team would put their various settings like anti-virus or particular GPO policies or whatever.  The point is thatin a container world, rather than creating the actual images, we simply create the dockerfiles.  Much like a restuarant creating a recipe for a meal rather than the actual meal.

2. From within the dockerfile.simple folder, run "docker build -t baseimage ." The name of the container image that will be created is "baseimage".

3. Open and discuss dockerfile.buildIIS.  Notice the "FROM" statement.  Change it to match whichever name you chose in step 1 ("baseimage", if you follow these instructions).  This file represents the work that a server/web team would do in order to prepare a naked VM to be a web/IIS server.  It demonstrates how to run PS inside the container image and activate Windows features and server roles.

4. From within the dockerfile.buildIIS folder, run "docker build -t baseIIS ."  The name of the container image that will be created is "baseIIS".
 
5. Open and discuss dockerfile.  Notice the "FROM" statement.  Change it to match whichever name you chose in step 4 ("baseIIS", if you follow these instructions).  This file represents the work that the app team would do. They've "scripted" the installation and configuration of the application completely within a single file

6. From the root directory, run "docker build -t final ."  This will create the final conatiner image that has the entire stack of layers built-in. It also has the application fully deployed and configured without any manual effort/steps.
