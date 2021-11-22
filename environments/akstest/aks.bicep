var aksName = 'testaks'
var aksLocation = 'eastus2'
var aksDnsPrefix = 'carluutestaks'

resource testAks 'Microsoft.ContainerService/managedClusters@2020-12-01' = {
  name: aksName
  location: aksLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    
    dnsPrefix: aksDnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool1'
        count: 1
        vmSize: 'Standard_DS2_v2'
        mode: 'System'
      }
    ]
    linuxProfile: {
      adminUsername: 'aksadmin'
      ssh: {
        publicKeys:[
          {
            keyData: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDLA4cpKswV4Tcvc8U8+MVuvDgZleCH0JI0hJPN2Xp+gf8edAOD2U/QUdN8KTz9fCxS/tH5NF+dh2P5G/f2vVfK0sW0N/Rq8IQmK7Mws/neyjfnY6z51wV7RrmHX1ZXOL3ihD0AknhpZcZ8qyxjrgng7lwFXBjMzd/okd1amiF5Z849PWCK/SB5AJmQrKVaFVUny+opquGBBCBCqfkXzsnqPShcLZ0kYmOpu3KGBgyUg5Gr4cUNw1NssAEB4HWj6XS4uYtk4S/35vRfiPfVEWdDqudblMKz53m5OV28FJOfbQg3QaQLA1jye8GB7nr6NxM+pwJc7uuC0XSfdVWlYLGMGbWYfpFltcLc2rYaQvZtuuNrk09/ts70c/RVf3ie1Ihrh9q9deTBFsgh9GXTZsAb2srhs6BZNSU0HyVCzEotxqY6MO7a1jl1hQrR18XVkyNtVlBoe6LdFX9qIcy4ZT9kKPiZIGJvn8zsjRGoj53BwGYgF+tjLScVVR9vIU81vF0='
          }
        ]
      }
    }
    /*
    identityProfile: {
      
    }
    servicePrincipalProfile: {
      clientId: aksSpClientId
      secret: aksSpClientSecret
    }*/
    
  }
}
