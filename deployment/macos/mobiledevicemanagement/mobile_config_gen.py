#!/usr/bin/python

# Copyright Elasticsearch B.V. and/or licensed to Elasticsearch B.V. under one
# or more contributor license agreements. Licensed under the Elastic License
# 2.0; you may not use this file except in compliance with the Elastic License
# 2.0.

import sys
import uuid
import argparse

template = """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>PayloadContent</key>
    <array>
        <dict>
            <key>PayloadDescription</key>
            <string></string>
            <key>PayloadDisplayName</key>
            <string>Privacy Preferences Policy Control</string>
            <key>PayloadEnabled</key>
            <true/>
            <key>PayloadIdentifier</key>
            <string>com.apple.TCC.configuration-profile-policy.{0}</string>
            <key>PayloadOrganization</key>
            <string>{6}</string>
            <key>PayloadType</key>
            <string>com.apple.TCC.configuration-profile-policy</string>
            <key>PayloadUUID</key>
            <string>{0}</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
            <key>Services</key>
            <dict>
                <key>SystemPolicyAllFiles</key>
                <array>
                    <dict>
                        <key>Allowed</key>
                        <integer>1</integer>
                        <key>CodeRequirement</key>
                        <string>identifier "64_Bit_Endpoint_Macos" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = "2BT3HPN62Z"</string>
                        <key>Identifier</key>
                        <string>/Library/Elastic/Endpoint/elastic-endpoint</string>
                        <key>IdentifierType</key>
                        <string>path</string>
                        <key>StaticCode</key>
                        <integer>1</integer>
                    </dict>
                    <dict>
                        <key>Allowed</key>
                        <integer>1</integer>
                        <key>CodeRequirement</key>
                        <string>identifier "co.elastic.systemextension" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = "2BT3HPN62Z"</string>
                        <key>Identifier</key>
                        <string>co.elastic.systemextension</string>
                        <key>IdentifierType</key>
                        <string>bundleID</string>
                        <key>StaticCode</key>
                        <integer>1</integer>
                    </dict>
                    <dict>
                        <key>Allowed</key>
                        <integer>1</integer>
                        <key>CodeRequirement</key>
                        <string>identifier "co.elastic.endpoint" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = "2BT3HPN62Z" </string>
                        <key>Identifier</key>
                        <string>co.elastic.endpoint</string>
                        <key>IdentifierType</key>
                        <string>bundleID</string>
                        <key>StaticCode</key>
                        <integer>1</integer>
                    </dict>
                </array>
            </dict>
        </dict>
        <dict>
            <key>FilterBrowsers</key>
            <true/>
            <key>FilterDataProviderBundleIdentifier</key>
            <string>co.elastic.systemextension</string>
            <key>FilterDataProviderDesignatedRequirement</key>
            <string>identifier "co.elastic.systemextension" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = "2BT3HPN62Z"</string>
            <key>FilterPacketProviderBundleIdentifier</key>
            <string>co.elastic.systemextension</string>
            <key>FilterPacketProviderDesignatedRequirement</key>
            <string>identifier "co.elastic.systemextension" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = "2BT3HPN62Z"</string>
            <key>FilterPackets</key>
            <true/>
            <key>FilterSockets</key>
            <true/>
            <key>FilterType</key>
            <string>Plugin</string>
            <key>PayloadDisplayName</key>
            <string>Web Content Filter Payload</string>
            <key>PayloadIdentifier</key>
            <string>com.apple.webcontent-filter.{1}</string>
            <key>PayloadOrganization</key>
            <string>{6}</string>
            <key>PayloadType</key>
            <string>com.apple.webcontent-filter</string>
            <key>PayloadUUID</key>
            <string>{1}</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
            <key>PluginBundleID</key>
            <string>co.elastic.endpoint</string>
            <key>UserDefinedName</key>
            <string>ElasticEndpoint</string>
        </dict>
        <dict>
            <key>AllowUserOverrides</key>
            <true/>
            <key>AllowedSystemExtensions</key>
            <dict>
                <key>2BT3HPN62Z</key>
                <array>
                    <string>co.elastic.systemextension</string>
                </array>
            </dict>
            <key>PayloadDescription</key>
            <string></string>
            <key>PayloadDisplayName</key>
            <string>System Extensions</string>
            <key>PayloadEnabled</key>
            <true/>
            <key>PayloadIdentifier</key>
            <string>com.apple.system-extension-policy.{2}</string>
            <key>PayloadOrganization</key>
            <string>{6}</string>
            <key>PayloadType</key>
            <string>com.apple.system-extension-policy</string>
            <key>PayloadUUID</key>
            <string>{2}</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
        </dict>
        <dict>
            <key>NotificationSettings</key>
            <array>
                <dict>
                    <key>AlertType</key>
                    <integer>2</integer>
                    <key>BadgesEnabled</key>
                    <true/>
                    <key>BundleIdentifier</key>
                    <string>co.elastic.alert</string>
                    <key>CriticalAlertEnabled</key>
                    <true/>
                    <key>NotificationsEnabled</key>
                    <true/>
                    <key>ShowInLockScreen</key>
                    <true/>
                    <key>ShowInNotificationCenter</key>
                    <true/>
                    <key>SoundsEnabled</key>
                    <true/>
                </dict>
            </array>
            <key>PayloadDisplayName</key>
            <string>Notifications Payload</string>
            <key>PayloadIdentifier</key>
            <string>com.apple.notificationsettings.{3}</string>
            <key>PayloadOrganization</key>
            <string>{6}</string>
            <key>PayloadType</key>
            <string>com.apple.notificationsettings</string>
            <key>PayloadUUID</key>
            <string>{3}</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
        </dict>
    </array>
    <key>PayloadDescription</key>
    <string>Grants Elastic Agent the necessary permissions to secure your Mac</string>
    <key>PayloadDisplayName</key>
    <string>Elastic Agent Endpoint Configuration</string>
    <key>PayloadEnabled</key>
    <true/>
    <key>PayloadIdentifier</key>
    <string>{4}</string>
    <key>PayloadOrganization</key>
    <string>{6}</string>
    <key>PayloadRemovalDisallowed</key>
    <true/>
    <key>PayloadScope</key>
    <string>System</string>
    <key>PayloadType</key>
    <string>Configuration</string>
    <key>PayloadUUID</key>
    <string>{5}</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
</dict>
</plist>

"""

def main(argv):

    name = str()
    output_file = str()

    parser = argparse.ArgumentParser()
    parser.add_argument("-n", "--name", help="The name of your company", action="store", required=True, type=str, dest="name")
    parser.add_argument("-o", "--output", help="The absolute path to the mobileconfig that will be written out by this script", action="store", required=True, type=str, dest="output_file_path")

    args = parser.parse_args()

    output_file = args.output_file_path

    # Ensure the file ends with .mobileconfig extension
    if output_file.endswith(".mobileconfig") == False:
        output_file += ".mobileconfig"


    with open(output_file, 'w', encoding='utf-8') as output_config_file:

        pos_args = [str(uuid.uuid4()).upper() for _ in range (0,6)]

        output_data = template.format(*pos_args, args.name)
        output_config_file.write(output_data)

if __name__ == "__main__":
    main(sys.argv[1:])

