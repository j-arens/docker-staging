# docker-staging

Test setup for deploying and hosting P7 wordpress staging sites to test pull requests. Built with docker, docker-compose, nginx, and some bash functions.

Steps to deploy:

1. Create a deployment directory with `mc_create_deploy_dir <branch-name> <commit-sha>`
2. Place built app in deploy directory, unzip with `mc_unzip_artifact <branch-name> <commit-sha> <target>` if needed
3. Change P7 sem-vers with `mc_update_p7_semver <branch-name> <commit-sha> <version>` if needed
4. Start a container with `mc_create_wp_service <staging-domain> <branch-name> <commit-sha> <user>`
5. Create a nginx vhost with `mc_create_proxy_conf <staging-domain> <branch-name> <commit-sha> <user>`

Container should be running and accessible at http://staging-domain.com/branch-name/user.
