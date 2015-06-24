module.exports =
    'port': 4610  # the base port for this instance (in production, pm2 will spawn multiple
                  # instances on port + instanceId)

    'salt': 10  # the number of bcrypt rounds to run for all stored passwords
