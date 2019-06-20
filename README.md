# joomla-docker

Docker files to deploy joomla and nginx dockers customized to the scos environment

## First Time Setup

This repository builds and deploys a docker image which has all of the dependencies to run joomla in kubernetes.

Since this does not contain the joomla files, these will need to be downloaded from the <env>-os-joomla-backups s3 bucket in the respective environment,
this zip archive will need to be copied and extracted to the joomla pod with the appropriate permissions

`kubectl cp ~/path/to/backup.zip joomla-pod-id:backup.zip`
`kubectl exec -itn joomla joomla-pod-id bash`
`apt-get update && apt-get install -y unzip`
`unzip backup.zip`
`chown -R www-data:www-data .`
`rm -rf installation/`
`rm -rf backup.zip`

Additionally you need a secret key to be in kubernetes for the akeeba backup to use

`k -n joomla create secret generic joomla-backup-key --from-literal=key=<key_here>`

This key can be found by logging into joomla and navigating to 

`System -> Global Configuration -> Akeeba Backup -> Frontend Backup -> Secret Word Field`

You may also need ot update the log path

`update "Path to Log Folder" under System > Global Configuration > System to "/var/www/html/tmp"`
