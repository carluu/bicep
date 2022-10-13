# bicep
# Compilation of bicep work

## Deployment Steps:
```
bicep build ./main.bicep # generates main.json  
az group create -n my-rg -l eastus # optional - create resource group 'my-rg'  
az deployment group create -f ./main.json -g my-rg
```

### Using a param file:
az deployment group create --template-file template.bicep  --parameters @params/parameters.json --resource-group rg
