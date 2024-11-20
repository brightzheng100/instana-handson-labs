# Lab 2.6 – Infrastructure Monitoring

## Step 3: Instana Dynamic Focus

```
# Fielded search
entity.host.cpu.count:>4

# Boolean operators
entity.host.cpu.count:<4 AND entity.zone:production

# Grouping
(entity.host.cpu.count:<4 AND entity.zone:production) OR entity.host.cpu.count:>4

# Wildcard searches
entity.type:container*
```
