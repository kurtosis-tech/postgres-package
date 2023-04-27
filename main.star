IMAGE_ARG_KEY = "image"
SERVICE_NAME_ARG_KEY = "name"
DATABASE_ARG_KEY = "database"
USER_ARG_KEY = "user"
PASSWORD_ARG_KEY = "password"

PORT_NAME = "postgresql"

def run(plan, args):

    image = args.get(IMAGE_ARG_KEY, "postgres:alpine")
    service_name = args.get(SERVICE_NAME_ARG_KEY, "postgres")
    user = args.get(USER_ARG_KEY, "postgres")
    password = args.get(PASSWORD_ARG_KEY, "MyPassword1!")
    database = args.get(DATABASE_ARG_KEY, "postgres")

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
            env_vars = {
                "POSTGRES_DB": database,
                "POSTGRES_USER": user,
                "POSTGRES_PASSWORD": password,
            },
        )
    )

    return struct(
        service = postgres_service,
        port = postgres_service.ports[PORT_NAME],
        user = user,
        password = password,
        database = database,
    )
