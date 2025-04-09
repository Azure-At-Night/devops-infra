Date=$(date +'%Y-%m-%dT%H-%M-%S')
TemplateFilePath='./bootstrap.bicep'
Location="centralus"
 
az deployment sub create \
  --name "bootstrap-tfstorage-$Date" \
  --location $Location \
  --template-file $TemplateFilePath \
  --what-if
