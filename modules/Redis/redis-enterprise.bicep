resource redis 'Microsoft.Cache/redisEnterprise@2021-03-01' = {
  properties: {
minimumTlsVersion: '1.2'
  }
  sku: {
    capacity: 2 // 2,4,6,etc. for non-flash
    name: 'Enterprise_E10' // Options are E10, E20, E50, E100 in non-flash
  }
  zones: [
    '3'
  ]
  name: 'cuutestredis'
  location: 'centralus'
  resource redisdb 'databases@2021-02-01-preview' = {
    name: 'redisdb'
    properties: {
      clientProtocol: 'Encrypted' // SSL required
      clusteringPolicy: 'EnterpriseCluster' // Whether to use the Redis or OSS API
      evictionPolicy: 'NoEviction' //https://redis.io/topics/lru-cache
      modules: [
        {
          name: 'RedisBloom' //Examples: RedisBloom, RediSearch, RedisTimeSeries
          args: 'ERROR_RATE 0.00'
        }
      ]
      persistence: { //https://docs.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-premium-persistence
        aofEnabled: true
        aofFrequency: '1s'
        rdbEnabled: false
        rdbFrequency: '1h'
      }
      port:  6379 //Will just pick one that's available if not specified
      geoReplication: {
        groupNickname: 'redisgeorepgroup'
        linkedDatabases: [
          {
            id: resourceId('Microsoft.Cache/redisEnterprise/databases','cuutestredis','redisdb')
          }
        ]
      }
    }
  }
}
