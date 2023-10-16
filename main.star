PORT_NAME = "postgresql"
APPLICATION_PROTOCOL = "postgresql"

CONFIG_FILE_MOUNT_DIRPATH = "/config"
SEED_FILE_MOUNT_PATH = "/docker-entrypoint-initdb.d"
DATA_DIRECTORY_PATH = "/data/"

CONFIG_FILENAME = "postgresql.conf"  # Expected to be in the artifact


def run(
    plan,
    image="postgres:alpine",
    service_name="postgres",
    user="postgres",
    password="MyPassword1!",
    database="postgres",
    config_file_artifact_name="",
    seed_file_artifact_name="",
    extra_configs=[],
    persistent=False,
):
    """Launches a Postgresql database instance, optionally seeding it with a SQL file script

    Args:
        image (string): The container image that the Postgres service will be started with
        service_name (string): The name to give the Postgres service
        user (string): The user to create the Postgres database with
        password (string): The password to give to the created user
        database (string): The name of the database to create
        config_file_artifact_name (string): The name of a files artifact that contains a Postgres config file in it
            If not empty, this will be used to configure the Postgres server
        seed_file_artifact_name (string): The name of a files artifact containing seed data
            If not empty, the Postgres server will be populated with the data upon start
        extra_configs (list[string]): Each argument gets passed as a '-c' argument to the Postgres server
        persistent (bool): Whether the data should be persisted. Defaults to False; Note that this isn't supported on multi node k8s cluster as of 2023-10-16
    Returns:
        An object containing useful information about the Postgres database running inside the enclave:
        ```
        {
            "database": "postgres",
            "password": "MyPassword1!",
            "port": {
                "application_protocol": "postgresql",
                "number": 5432,
                "transport_protocol": "TCP",
                "wait": "2m0s"
            },
            "service": {
                "hostname": "postgres",
                "ip_address": "172.16.0.4",
                "name": "postgres",
                "ports": {
                    "postgresql": {
                        "application_protocol": "postgresql",
                        "number": 5432,
                        "transport_protocol": "TCP",
                        "wait": "2m0s"
                    }
                }
            },
            "url": "postgresql://postgres:MyPassword1!@postgres/postgres",
            "user": "postgres"
        }
        ```
    """
    cmd = []
    files = {}
    env_vars = {
        "POSTGRES_DB": database,
        "POSTGRES_USER": user,
        "POSTGRES_PASSWORD": password,
    }

    if persistent:
        files[DATA_DIRECTORY_PATH] = Directory(
            persistent_key="postgres_data_folder",
        )
        env_vars["PGDATA"] = DATA_DIRECTORY_PATH

    if config_file_artifact_name != "":
        config_filepath = CONFIG_FILE_MOUNT_DIRPATH + "/" + CONFIG_FILENAME
        cmd += ["-c", "config_file=" + config_filepath]
        files[CONFIG_FILE_MOUNT_DIRPATH] = config_file_artifact_name

    # append cmd with postgres config overrides passed by users
    if len(extra_configs) > 0:
        for config in extra_configs:
            cmd += ["-c", config]

    if seed_file_artifact_name != "":
        files[SEED_FILE_MOUNT_PATH] = seed_file_artifact_name

    postgres_service = plan.add_service(
        name=service_name,
        config=ServiceConfig(
            image=image,
            ports={
                PORT_NAME: PortSpec(
                    number=5432,
                    application_protocol=APPLICATION_PROTOCOL,
                )
            },
            cmd=cmd,
            files=files,
            env_vars=env_vars,
        ),
    )

    url = "{protocol}://{user}:{password}@{hostname}/{database}".format(
        protocol=APPLICATION_PROTOCOL,
        user=user,
        password=password,
        hostname=postgres_service.hostname,
        database=database,
    )

    return struct(
        url=url,
        service=postgres_service,
        port=postgres_service.ports[PORT_NAME],
        user=user,
        password=password,
        database=database,
    )


def run_query(plan, service, user, password, database, query):
    url = "{protocol}://{user}:{password}@{hostname}/{database}".format(
        protocol=APPLICATION_PROTOCOL,
        user=user,
        password=password,
        hostname=service.hostname,
        database=database,
    )
    return plan.exec(
        service.name, recipe=ExecRecipe(command=["psql", url, "-c", query])
    )
