IMAGE_ARG_KEY = "image"
SERVICE_NAME_ARG_KEY = "name"
DATABASE_ARG_KEY = "database"
USER_ARG_KEY = "user"
PASSWORD_ARG_KEY = "password"
CONFIG_FILE_ARTIFACT_ARG_KEY = "configFileArtifact"

PORT_NAME = "postgresql"

CONFIG_FILE_MOUNT_DIRPATH = "/config"
CONFIG_FILENAME = "postgresql.conf"  # Expected to be in the artifact

def run(plan, args):

    image = args.get(IMAGE_ARG_KEY, "postgres:alpine")
    service_name = args.get(SERVICE_NAME_ARG_KEY, "postgres")
    user = args.get(USER_ARG_KEY, "postgres")
    password = args.get(PASSWORD_ARG_KEY, "MyPassword1!")
    database = args.get(DATABASE_ARG_KEY, "postgres")
    config_file_artifact_name = args.get(CONFIG_FILE_ARTIFACT_ARG_KEY, "")

    cmd = []
    if config_file_artifact_name != "" {
        config_filepath = CONFIG_FILE_MOUNT_DIRPATH + "/" + CONFIG_FILENAME
        cmd += ["-c", "config_file=" + config_filepath]
    }

    postgres_service = plan.add_service(
        name = service_name,
        config = ServiceConfig(
            image = image,
            ports = {
                PORT_NAME: PortSpec(
                    number = 5432,
                    application_protocol = "postgresql",
                )
            },
            cmd = cmd,
            env_vars = {
                "POSTGRES_DB": database,
                "POSTGRES_USER": user,
                "POSTGRES_PASSWORD": password,
            },
            files = {
                CONFIG_FILE_MOUNT_DIRPATH: config_file_artifact_name,
            }
        )
    )

    return struct(
        service = postgres_service,
        port = postgres_service.ports[PORT_NAME],
        user = user,
        password = password,
        database = database,
    )
