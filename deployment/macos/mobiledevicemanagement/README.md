This script will generate a .mobileconfig file that you can use with your particular MDM provider to deploy Elastic Endpoint throughout your organization silently. This MDM profile will automatically grant all permissions and approvals nessecary to run Elastic Endpoint

Requires Python3

usage: mobile_config_gen.py [-h] -n NAME -o OUTPUT_FILE_PATH

optional arguments:
  -h, --help            show this help message and exit
  -n NAME, --name NAME  The name of your company
  -o OUTPUT_FILE_PATH, --output OUTPUT_FILE_PATH
                        The absolute path to the mobileconfig that will be
                        written out by this script