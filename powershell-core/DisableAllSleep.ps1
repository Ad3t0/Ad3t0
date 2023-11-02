# Disable Sleep
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\238C9FA8-0AAD-41ED-83F4-97BE242C8F20\29f6c1db-86da-48c5-9fdb-f2b67b1f44da" -Name "Attributes" -Value 2

# Disable Hibernate
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power" -Name "HibernateEnabled" -Value 0
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0

# Disable Hybrid Sleep
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\238C9FA8-0AAD-41ED-83F4-97BE242C8F20\94AC6D29-73CE-41A6-809F-6363BA21B47E" -Name "Attributes" -Value 2

# Prevent Sleep with Power Button
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82BE-4824-96C1-47B60B740D00\7648efa3-dd9c-4e3e-b566-50f929386280" -Name "Attributes" -Value 2

# Prevent Sleep with Lid Close
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82BE-4824-96C1-47B60B740D00\5ca83367-6e45-459f-a27b-476b1d01c936" -Name "Attributes" -Value 2

Write-Output "Registry changes applied successfully. Consider restarting your system for the changes to take effect."
