import subprocess
from abc import ABC, abstractmethod
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from subprocess import CompletedProcess

from rich import print
from typer import Typer

project_root: Path = Path(__file__).parent

docker_username: str = "zjlabbrainscience"
image_repo_prefix: str = "zj-brain-science-platform"
image_version: str = datetime.now().strftime("%Y%m%d%H%M%S")


def run(executable: str, *args, check=True, **kwargs) -> CompletedProcess:
    command = [executable, *args]
    print(f":rocket: [bold red]RUN[/bold red] {' '.join(command)}")
    process = subprocess.run(command, check=check, **kwargs)
    return process


class Executable(ABC):
    @abstractmethod
    def execute(self, *args, check=True, **kwargs) -> CompletedProcess:
        pass


@dataclass
class DockerBuild(Executable):
    dockerfile: Path
    path: Path
    repo: str
    version: str | None

    @property
    def tag(self) -> str:
        tag = f"{docker_username}/{self.repo}"
        if self.version is not None:
            tag = f"{tag}:{self.version}"
        return tag

    def execute(self, *args, check=True, **kwargs) -> CompletedProcess:
        return run(
            "docker",
            "build",
            "--file",
            str(self.dockerfile),
            "--tag",
            self.tag,
            str(self.path),
            check=check,
            **kwargs,
        )

    def push(self) -> CompletedProcess:
        return run(
            "docker",
            "push",
            f"{docker_username}/{self.tag}"
        )


app = Typer()


@app.command()
def login_docker():
    run(
        "docker",
        "login"
    )


@app.command()
def build_and_push_poetry():
    poetry_build = DockerBuild(
        dockerfile=(project_root / "poetry.Dockerfile"),
        path=project_root,
        repo=f"{image_repo_prefix}-poetry",
        version=image_version,
    )
    poetry_build.execute()
    login_docker()
    poetry_build.push()


if __name__ == '__main__':
    app()
