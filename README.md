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

Follow the steps above under First Time Setup but skip the `rm -rf installation` you should then be able to navigate to the URL and it will guide you to the installation/restore process. More information can be found at https://docs.joomla.org/J3.x:Updating_from_an_existing_version

## Upgrading Joomla and associate plugins
Here are the steps required to upload the main Joomla version, as well as any other plugins that require updating. This example uses https://www.staging-smartos.com as the site to be upgraded.

### Perform pre-upgrade backup
- Navigate to https://www.staging.internal.smartcolumbusos.com/administrator/index.php?option=com_akeeba&view=Backup
- Give the backup a helpful description, such as "Backing up before upgrade"
- Click the "Backup Now!" button

### Perform pre-upgrade smoke test
- Clone down https://github.com/SmartColumbusOS/joomla-smoke-tests
- Update the `baseUrl` field in `cypress.json` to point to the Joomla site you're upgrading (https://www.staging-smartos.com/ in our case)
- Run the command `npm i`
- Run the command `npm run cypress:run:update` to take a snapshot of all relevant pages of the site so we can compare them after the upgrade. NOTE: this will have several failures for the dev joomla since it's so far out of date with prod

### Perform the upgrade
- Navigate to https://www.staging.internal.smartcolumbusos.com/administrator/index.php?option=com_joomlaupdate
- Click the "Install the update" button
- Wait for it to succeed
- If it fails, and you don't want to proceed any further jump to the `Perform post-upgrade smoke test` section to verify nothing was broken

### Verify database tables are fine
- Navigate to https://www.staging.internal.smartcolumbusos.com/administrator/index.php?option=com_installer&view=database
- Verify that the output looks something like the below:
```
Database schema version (in #__schemas): 3.9.19-2020-06-01.
Update version (in #__extensions): 3.9.19.
Database driver: mysqli.
187 database changes were checked.
212 database changes did not alter table structure and were skipped.
```
- If it doesn't, you will be prompted with a "Fix" button. Click it.
- If that doesn't work, refer to the Joomla upgrade document mentioned at the beginning of this upgrade section

### Verify that no new, essential extensions are available
- Navigate to https://www.staging.internal.smartcolumbusos.com/administrator/index.php?option=com_installer&view=discover
- Click on the "Discover" button
- Confirm there are no extensions to install
- If there are, just install them without worrying about it, I'm sure it's fine

### Update plugins with updates available
- Navigate to https://www.staging.internal.smartcolumbusos.com/administrator/index.php?option=com_installer&view=update
- Click the top checkbox to select all plugins
- Click the "Update" button
- Presently (as of 6/29/2020), at least 5 plugins require you to log into a site, download the zip and upload it to Joomla. Feel free to skip these if they give you errors
  - Google No Captcha ReCAPTCHA
  - JCE Pro
  - LOGman
  - RSForm! Pro
  - SP Page Builder Pro

### Perform post-upgrade smoke test
- Use the same local repository of `joomla-smoke-tests` as in the pre-upgrade smoke test, as it will have updated images for you to diff against
- Make sure the `baseUrl` field in `cypress.json` points at the site you've upgraded (https://www.staging-smartos.com/ in our case)
- Run the command `npm run cypress:run` to take new snapshots of all Joomla pages and diff them against the ones you took before the upgrade
- If this fails, review the diffs and if they seem too off (entire pages missing or big pieces of content missing) then restore the pre-upgrade backup you took using the steps in the section titled `(Optional) restoring pre-upgrade backup, if necessary`

### Perform post-upgrade backup
- Navigate to https://www.staging.internal.smartcolumbusos.com/administrator/index.php?option=com_akeeba&view=Backup
- Give the backup a helpful description, such as "Backing up after upgrade"
- Click the "Backup Now!" button

### (Optional) restoring pre-upgrade backup, if necessary
- If things went poorly, then navigate to https://www.staging.internal.smartcolumbusos.com/administrator/index.php?option=com_akeeba&view=Manage
- Check the box for the pre-upgrade backup.
- Click on the "Restore" button
- It should just work
