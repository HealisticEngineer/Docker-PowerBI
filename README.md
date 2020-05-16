# Power Bi Reporting Services in Docker

creates a fresh install of SSRS in a container - pretty useful for dev / test - not for production use!

## Run it

This sample is uses mcr.microsoft.com/windows/servercore:ltsc2019 as a parent image and accepts all the commands listed there:

In addtion it accepts two more env variables: </br>

- **pbirs_user**: Name of a new admin user that will be created to login to report server
- **pbirs_password**: Sets the password for the admin user

example:

```
docker run -d -p 1433:1433 -p 80:80 -v C:/temp/:C:/temp/ -e sa_password=<YOUR SA PASSWORD> -e ACCEPT_EULA=Y -e pbirs_user=PBIAdmin -e pbirs_password=<YOUR PBIAdmin PASSWORD> --memory 6048mb phola/ssrs
```

then access PowerBI Report Server at http://localhost/reports and login using pbirs_user

## Tips

- **-p 80:80** to access report manager in browser
- **--memory 6048mb** to bump RAM

## Disclaimers

PowerBi is defintely not supported in containers..

## License

MIT license. See the [LICENSE file](LICENSE) for more details.
