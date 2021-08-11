import os
import argparse

from dataclasses import dataclass
from pathlib import Path

from dotenv import load_dotenv
from jinja2 import Environment, FileSystemLoader
from python_terraform import Terraform


FILE_PATH = os.path.abspath(__file__)
PROJECT_ROOT = Path(FILE_PATH).parents[1]
DEPLOYMENT_PATH = Path(FILE_PATH).parents[1] / "src/functions/FunctionApp/"
TARGET_ENV_FILE = DEPLOYMENT_PATH / "local.settings.json"


def load_config():
    deployment_folder_path = (
        f"{os.path.dirname(os.path.realpath(__file__))}/../src/edge/deployments/"
    )
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
        return template_env.get_template("local.settings.template.json")

    def get_context(self):
        """Create the context with variables for the Jinja template"""
        output = self._get_terraform_output()

        return output

    def _get_terraform_output(self):
        """
        Returns terraform output for the given environment
        :returns: Dict: Key value pairs of the terraform output
        """
        terraform_folder_path = PROJECT_ROOT / "terraform"

        print(f"Getting terraform output from: {terraform_folder_path}")

        tf = Terraform(working_dir=terraform_folder_path)
        return {k: v["value"] for k, v in tf.output().items()}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    ConfigGenerator().generate()
