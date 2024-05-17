<b>About this script</b>

This script contains everything you need to configure Native OTP Feature of NetScaler.
Native OTP is the Nescaler's built in OTP solution which includes a self service portal. The number of enrolled tokens will be limited to 2 (default value is 4).

<br>
<b>Before running this script</b>

Make sure you have an LDAP service account which is able to write information in LDAP attribute "userParameters"

<br>
<b>Manual steps after running the script</b>

Because I don't want to break any running configuration on the ADC, there are some last manual steps to do: 
- Bind the new created authentication profile to the gateway VServer
- Bind the new created traffic policy to the gateway VServer