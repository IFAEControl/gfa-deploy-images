## How to

To install client components of a release use the next script:

`utils/deploy_client.sh <dir> <release>`

where **dir** is the directory where the python virtual environment will be created and release the release folder, for example: `utils/deploy_client.sh /tmp 201810160939`

This script will install all the libraries and dependencies. To activate this virtual environment we simply have to execute `source <dir>/gfa_venv/bin/activate`