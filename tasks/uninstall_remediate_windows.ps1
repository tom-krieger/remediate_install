[CmdletBinding()]
Param(
  [Parameter(Mandatory = $True)]
 [String] $install_dir
)

cd $install_dir

docker-compose run remediate stop

docker service ls | grep remediate_ | awk '{print $1;}' | while read srv ; do 

    docker service rm $srv
    
done

$Services = (docker service ls) | Out-String | findstr "remediate_"
foreach ($srv in $Services) {
  $data = $cont -split "\s+"
  $id = $data[0]
  $img = $data[1]
  docker service rm $id
}

$Containers = (docker ps -a) | Out-String | findstr "remediate_"
foreach ($cont in $Containers) {
  $data = $cont -split "\s+"
  $id = $data[0]
  $img = $data[1]

  docker stop $id
  docker rm $id
  docker image rm $img
}

$Images = (docker image ls) | Out-String | findstr "gcr.io/puppet-discovery vault"
foreach ($line in $Images) {
  $data = $line -split "\s+"
  $img = $data[2]
  docker image rm $img
}

$SECRETS="aadmin_password
admin_user
audit.crt
audit.key
controller.crt
controller.key
edge.crt
edge.key
encryption_key.txt
export.crt
export.key
frontdoor.crt
frontdoor.key
gopdp.crt
gopdp.key
identity.crt
identity.key
identity_realm.json
licensing.crt
licensing.key
oauth_client.json
root.crt
storage.crt
storage.key
ui.crt
ui.key
remote-edge.crt
remote-edge.key
root.key
vault.crt
vault.key
vr.crt
vr.key"

foreach ($secret in $SECRETS) {
  docker secret rm $secret
}

$Volumes = (docker volume ls) | Out-String | findstr "remediate_"
foreach ($line in $Volumes) {
  $data = $line -split "\s+"
  $vol = $data[1]

  docker volume rm $vol
}
