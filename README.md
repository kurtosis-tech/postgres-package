Postgres Package
================
This is a [Kurtosis package](https://docs.kurtosis.com/concepts-reference/packages) for starting a Postgres instance.

Run this package
----------------
If [you have Kurtosis installed][install-kurtosis], you can run: 

```bash
kurtosis run github.com/kurtosis-tech/postgres-package
```

If you don't have Kurtosis installed, [click here to run this package on the Kurtosis playground](https://gitpod.io/#KURTOSIS_PACKAGE_LOCATOR=github.com%2Fkurtosis-tech%2Fpostgres-package/https://github.com/kurtosis-tech/playground-gitpod).

The information for accessing the Postgres port will be outputted as a result of the run:

```
========================================== User Services ==========================================
UUID           Name       Ports                                                  Status
d411d8452f44   postgres   postgresql: 5432/tcp -> postgresql://127.0.0.1:65332   RUNNING
```

To blow away the created [enclave][enclaves-reference], run `kurtosis clean -a`.

#### Return value

See the "Using this package in your package" section below.


#### Configuration

<details>
    <summary>Click to see configuration</summary>

You can configure this package using the following JSON structure (though note that `//` lines aren't valid JSON, so you must remove them!). The default value each parameter will take if omitted is shown here:

```javascript
{
    // The Docker image that will be run
    "image": "postgres:alpine",

    // The name given to the service that gets added
    "name": "postgres",

    // The name of the user that will be created
    "user": "postgres",

    // The password given to the created user
    "password": "MyPassword1!",

    // The name of the database that will be created
    "database": "postgres",

    // The name of a files artifact (https://docs.kurtosis.com/concepts-reference/files-artifacts) that should contain 
    // a 'postgresql.conf' file for configuring the database.
    // The default value indicates that no custom config file will be used
    "configFileArtifact": ""
}
```

For example:

```bash
kurtosis run github.com/kurtosis-tech/postgres-package '{"image":"postgres:15.2-alpine","user":"johnsnow"}'
```

</details>

Use this package in your package
--------------------------------
Kurtosis packages can be composed inside other Kurtosis packages. To use this package in your package...

First, import this package by adding the following to the top of your Starlark file:

```python
postgres = import_module("github.com/kurtosis-tech/postgres-package/main.star")
```

Then, call the this package's `run` function somewhere in your Starlark script:

```python
postgres_output = postgres.run(plan, args)
```

The `run` function of this package will return a struct with the following properties:

```python
postgres_output = postgres.run(plan, args)

# A convenience URL for depending on the started Postgres, of the form postgresql://USER:PASSWORD@HOSTNAME/DATABASE
postgres_output.url

# An Service object instance (see https://docs.kurtosis.com/starlark-reference/service)
# Used to get information about the Postgres instance
postgres_output.service

# A PortSpec object containing information about the port Postgres is listening on (see https://docs.kurtosis.com/starlark-reference/port-spec)
postgres_output.port

# The user that the Postgres service was created with
postgres_output.user

# The password the user was created with
postgres_output.password

# The name of the Postgres database
postgres_output.database
```

This can be used to depend on the created Postgres service:

```python
postgres_output = postgres.run(plan, args)

# Depends on Postgres
plan.add_service(
    name = "my-app",
    config = ServiceConfig(
        image = "my-app",
        env_vars = {
            "POSTGRES": postgres_output.url,
        }
    )
)
```

Develop on this package
-----------------------
1. [Install Kurtosis][install-kurtosis]
1. Clone this repo
1. For your dev loop, run `kurtosis clean -a && kurtosis run .` inside the repo directory


<!-------------------------------- LINKS ------------------------------->
[install-kurtosis]: https://docs.kurtosis.com/install
[enclaves-reference]: https://docs.kurtosis.com/concepts-reference/enclaves
[service-reference]: https://docs.kurtosis.com/starlark-reference/plan
