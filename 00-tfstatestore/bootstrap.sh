Date=$(date +'%Y-%m-%dT%H-%M-%S')
TemplateFilePath='./bootstrap.bicep'
 
az deployment sub create \
  --name "bootstrap-tfstorage-$Date" \
  --location "centralus" \
  --template-file $TemplateFilePath \
  --what-if
