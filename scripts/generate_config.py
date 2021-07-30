import os
import argparse

from dataclasses import dataclass
from pathlib import Path

from dotenv import load_dotenv
from jinja2 import Environment, FileSystemLoader
from python_terraform import Terraform


FILE_PATH = os.path.abspath(__file__)
PROJECT_ROOT = Path(FILE_PATH).parents[1]
DEPLOYMENT_PATH = Path(FILE_PATH).parents[1] /"src/deployments"
TARGET_ENV_FILE = DEPLOYMENT_PATH / ".env"


def load_config():
    deployment_folder_path = f"{os.path.dirname(os.path.realpath(__file__))}/../src/deployments/"
    load_dotenv(f"{deployment_folder_path}.env")


@dataclass()
class ConfigGenerator:
    """
    This class generates a deployment/.env file from deployment/.env.template,
    using the specified environments terraform output
    :param environment: string: Terraform environment to get output from
    :param use_mock_grpc: bool: Set true for gRPC to send mock inferencing
    :param is_gpu: bool: Set true when running GPU enabled containers with GPU VM's
    """

    environment: str = "local-development"
    use_mock_grpc: bool = False
    is_gpu: bool = False

    def generate(self):
        print(f"Using project root  : {PROJECT_ROOT}")
        print(f"with deployment path: {DEPLOYMENT_PATH}")
        print(f"to write .env file  : {TARGET_ENV_FILE}")
        print("---------")
        """Generate .env from template"""
        print("Starting .env file generation")
        content = self.get_env_file_content()
        with open(TARGET_ENV_FILE, "w") as f:
            f.write(content)
            print(f".env file written to {TARGET_ENV_FILE}")

    def get_env_file_content(self):
        template = self.get_template()
        context = self.get_context()
        return template.render(context)

    def get_template(self):
        print(f"Loading template from {TARGET_ENV_FILE}.template")
        template_loader = FileSystemLoader(DEPLOYMENT_PATH)
        template_env = Environment(loader=template_loader, autoescape=False)
        return template_env.get_template(".env.template")

    def get_context(self):
        """Create the context with variables for the Jinja template"""
        output = self._get_terraform_output()

        ec = self._get_edge_config()
        sp = self._get_service_principal()
        env = {
            "ENVIRONMENT": self.environment,
        }
        return {**output, **sp, **ec, **env}

    def _get_terraform_output(self):
        """
        Returns terraform output for the given environment
        :returns: Dict: Key value pairs of the terraform output
        """
        terraform_folder_path = PROJECT_ROOT / "terraform" 

        print(f"Getting terraform output from: {terraform_folder_path}")

        tf = Terraform(working_dir=terraform_folder_path)
        return {k: v["value"] for k, v in tf.output().items()}

    def _get_edge_config(self):
        config = {
            "GPU_RUNTIME": "nvidia" if self.is_gpu else "runc",
            "USE_MOCK_GRPC": self.use_mock_grpc,
            "IPC_MODE": "container",
        }

        print(f"Setting up edge config with {config}")

        return config

    def _get_service_principal(self):
        dotenv_path = PROJECT_ROOT / "default.env"

        print("Getting the service principal information")

        if dotenv_path.is_file():
            print("default.env found, loading the file")
            load_dotenv(dotenv_path)

        client_id_name = "ARM_CLIENT_ID"
        client_id = os.getenv(client_id_name, "")

        client_secret_name = "ARM_CLIENT_SECRET"
        client_secret = os.getenv(client_secret_name, "")

        tenant_id_name = "ARM_TENANT_ID"
        tenant_id = os.getenv(tenant_id_name, "")

        env_vars = {client_id_name, client_secret_name, tenant_id_name}

        if not os.environ.keys() >= env_vars:
            missing_env_vars = [k for k in env_vars if k not in os.environ]
            print(f"Required variable(s) not set: {missing_env_vars} in default.env or as environment variables")
            print("WARNING: Aborting setting service principal info")
            return {}

        credentials = " ".join([client_id, client_secret])
        return {
            "CREDENTIALS": credentials,
            "SERVICE_PRINCIPAL": " ".join([credentials, tenant_id]),
            "AAD_SERVICE_PRINCIPAL_ID": client_id,
            "AAD_SERVICE_PRINCIPAL_SECRET": client_secret,
        }


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-e",
        "--environment",
        choices=["local-development", "development"],
        help="Terraform environment to get output from. Must have applied terraform before running this. (default: local-development)",
        default="local-development",
    )
    parser.add_argument(
        "-mg",
        "--mock-grpc",
        action="store_true",
        help="Set gRPC to send mock inferencing (default: real inferencing)",
    )
    parser.add_argument(
        "-g",
        "--gpu",
        action="store_true",
        help="Set when running GPU enabled containers with GPU VM's (default: no GPU)",
    )

    args = parser.parse_args()
    ConfigGenerator(args.environment, args.mock_grpc, args.gpu).generate()
