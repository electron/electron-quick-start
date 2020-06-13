#!/bin/bash

MACHINE_TYPE=`uname -m`

command -v pwsh >/dev/null 2>&1 || {
  echo "cannot find powershell, installing"
  if [ ${MACHINE_TYPE} == 'x86_64' ]; then
    #ubuntu install
    snap install powershell --classic
    ln -s /snap/bin/pwsh /usr/bin/pwsh
  else
    #raspbian install
    # install the requirements
    apt-get install '^libssl1.0.[0-9]$' libunwind8 -y

    # Download the powershell '.tar.gz' archive
    curl -L https://github.com/PowerShell/PowerShell/releases/download/v7.0.1/powershell-7.0.1-linux-arm32.tar.gz -o /tmp/powershell.tar.gz

    # Create the target folder where powershell will be placed
    mkdir -p /opt/microsoft/powershell/7

    # Expand powershell to the target folder
    tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7

    # Set execute permissions
    chmod +x /opt/microsoft/powershell/7/pwsh

    # Create the symbolic link that points to pwsh
    ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh
  fi
}
