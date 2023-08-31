PORT_NAME = "postgresql"
APPLICATION_PROTOCOL = "postgresql"

CONFIG_FILE_MOUNT_DIRPATH = "/config"
SEED_FILE_MOUNT_PATH = "/docker-entrypoint-initdb.d"

CONFIG_FILENAME = "postgresql.conf"  # Expected to be in the artifact

def run(
    plan,
    image = "postgres:alpine",  # type: string
    name ="postgres",           # type: string
    user = "postgres",          # type: string
    password = "MyPassword1!",  # type: string
    database = "postgres",      # type: string

    # The name of a files artifact that contains a Postgres config file in it
    # If not empty, this will be used to configure the Postgres server
    config_file_artifact_name = "", # type: string

    # The name of a files artifact containing seed data
    # If not empty, the Postgres server will be populated with the data upon start
    seed_file_artifact_name = "",   # type: string

    # Each argument gets passed as a '-c' argument to the Postgres server
    extra_configs = [],
):
    cmd = []
    files = {}
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
        name = service_name,
        config = ServiceConfig(
            image = image,
            ports = {
                PORT_NAME: PortSpec(
                    number = 5432,
                    application_protocol = APPLICATION_PROTOCOL,
                )
            },
            cmd = cmd,
            env_vars = {
                "POSTGRES_DB": database,
                "POSTGRES_USER": user,
                "POSTGRES_PASSWORD": password,
            },
            files = files,
        )
    )

    url = "{protocol}://{user}:{password}@{hostname}/{database}".format(
        protocol = APPLICATION_PROTOCOL,
        user = user,
        password = password,
        hostname = postgres_service.hostname,
        database = database,
    )

    return struct(
        url = url,
        service = postgres_service,
        port = postgres_service.ports[PORT_NAME],
        user = user,
        password = password,
        database = database,
    )

def run_query(plan, service, user, password, database, query):
    url = "{protocol}://{user}:{password}@{hostname}/{database}".format(
        protocol = APPLICATION_PROTOCOL,
        user = user,
        password = password,
        hostname = service.hostname,
        database = database,
    )
    return plan.exec(service.name, recipe=ExecRecipe(command=["psql", url, "-c", query]))
