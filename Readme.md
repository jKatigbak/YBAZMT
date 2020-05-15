### To get it set up
- make sure terraform is installed and aws is configured
- change var.source_ips, and var.private_key_path and var.public_key_path in provision_all.tf
- terraform init, plan, apply to get ec2 instance up
- in browser: <ec2-public-ip>:8080
 #### Notes: 
 - default: t2.micro (bump machine type if you want to use `make multi-build-binary`)
 - if remote-exec complains `/tmp/terraform_<some#>.sh: can't be found` make sure that bootstrap.sh is in unix format (`dos2unix bootstrap.sh` is helpful)
 - has most of the images/packages/repos set to the latest commits/releases (not 'latest')
 - in the case that the last command (make run) from remote-exec doesn't work, you'll need to ssh into the box and `sudo make -C /tmp/ run` to get it to appear on 8080 in the browser
 - if you want the binary you'll need to `sudo make -c /tmp/ build-binary-container && sudo make -c /tmp/ extract` to take it out of the go container  
 
 