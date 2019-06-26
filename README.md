# joomla-docker

Docker files to deploy a image with apache to host the joomla core files and content

A persistent volume is created and connected to the pod to host the joomla installation and content. 

## First Time Setup

This repository builds and deploys a docker image which has all of the dependencies to run joomla in kubernetes.

Since this does not contain the joomla files, these will need to be downloaded from the environment specific os-joomla-backups s3 bucket in the respective environment,
this zip archive will need to be copied and extracted to the joomla pod with the appropriate permissions

```bash
kubectl cp ~/path/to/backup.zip joomla-pod-id:backup.zip
kubectl exec -itn joomla joomla-pod-id bash
apt-get update && apt-get install -y unzip
unzip backup.zip
chown -R www-data:www-data .
rm -rf installation/
rm -rf backup.zip
```
Additionally you need a secret key to be in kubernetes for the akeeba backup to use

`kubectl -n joomla create secret generic joomla-backup-key --from-literal=key=<key_here>`

This key can be found by logging into joomla and navigating to 

`System -> Global Configuration > Akeeba Backup > Frontend Backup > Secret Word Field`

## Configuration
Most of the joomla configuration is stored in the datbase or the configuration.php file.  When moving the site to a new/different URL you must update the $live_site URL in the configuration.php file.

## Running a backup
Backups are run nightly on the joomla content and on the RDS database.

A manual Akeeba backup can be run by issuing the following command:
```bash
kubectl -n joomla create job joomla-backup-1 --from=cronjob/joomla-backup
```

## Complete failure recovery 
If you lose the database and persistent volume, or if you are setting up joomla for the first time in a new environment:

Follow the steps above under First Time Setup but skip the `rm -rf installation` you should then be able to navigate to the URL and it will guide you to the installation/restore process.
