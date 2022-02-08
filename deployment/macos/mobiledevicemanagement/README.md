This script will generate a .mobileconfig file that you can use with your particular MDM provider to deploy Elastic Endpoint throughout your organization silently. This MDM profile will automatically grant all permissions and approvals nessecary to run Elastic Endpoint

Requires Python3

usage: mobile_config_gen.py [-h] -n \<Name of your org\> -o \<Absolute path to write .mobileconfig file\>