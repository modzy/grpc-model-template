import os
import tarfile
from shutil import copytree, rmtree

import requests

from grpc_model import ASSET_BUNDLE as _ASSET_BUNDLE
from grpc_model import REPO_ROOT as _REPO_ROOT


def import_model(importer_port: int):
    importer_base_url = f"http://0.0.0.0:{importer_port}"

    # Check to see if the importer is actually running, and available on your machine
    respose = requests.post(f"{importer_base_url}/status")
    if not (respose.status_code == 200 and respose.reason == "OK"):
        print(f"Model Importer does not appear to be running on port {importer_port}")
        return

    # Create an archive with all versions of the current model inside
    temp_dir = _REPO_ROOT / "models"
    model_dir = temp_dir / "model_one"
    copytree(_ASSET_BUNDLE, model_dir)

    temp_tar_file = model_dir / "temp_models_archive.tar.gz"
    with tarfile.open(temp_tar_file, "w:gz") as archive:
        archive.add(temp_dir, recursive=True, arcname=os.path.basename(temp_dir))

    # Model Import
    with open(temp_tar_file, "rb") as tarfile_bytes:
        import_response = requests.post(
            f"{importer_base_url}/import?m=all", data=tarfile_bytes, headers={"Content-Type": "application/gzip"}
        )
        print(import_response.content.decode())

    # Teardown step to remove intermediate tarfile
    rmtree(temp_dir)


if __name__ == "__main__":
    import_model(91)
