<b>About this script</b>

There are situations where it is necessary to make the manageotp site public available. To protect this via LDAP Login only does not provide adequate security.
So this script creates a Native OTP solution and protects the manageotp site with a second factor. This factor is email-OTP. 
This one time password is send to the customers company mail address.

<b>Before running this Script</b>
Make sure you have an LDAP service account which is able to write information in LDAP attribute "userParameters"

<b>Manual steps after running the Script</b>
Because I don't want to break any running configuration on the ADC, there are some last manual steps to do:

- Bind the new created authentication profile to the gateway VServer
- Bind the new created traffic policy to the gateway VServer