**Tests ran with:**
- Java 11 (OpenJDK Runtime Environment GraalVM CE 19.3.5 (build 11.0.10+8-jvmci-19.3-b22)
- BAMOE 8.0.41
- EAP 7.4.4

To run this setup, you must add to the `installs` folder, the following files:
- jboss-eap-7.4.0.zip 
- bamoe-8.0.4-business-central-eap7-deployable.zip
- jboss-eap-7.4.4-patch.zip 
- bamoe-8.0.4-kie-server-ee8.zip
- jbpm-wb-kie-server-backend-7.67.2-DBACLD-118447.jar


**Setup the environment**

Install two EAPs, one for Business Central and one for KIE Server using the automated installation:

`./init.sh`

**Business Central**

- Business Central is installed on `patch-install-reproducer/bamoe/bc/`, 
- uses `standalone-full.xml` by default
- accessible via http://localhost:8080/business-central: 
- Access
  - **usr**: `pamAdmin`, **pwd**: `ibmpam1`, **roles**: analyst,admin,manager,user,kie-server,kiemgmt,rest-all 
  - **usr**: `karina`, **pwd**: `karina`, **roles**: user,developer,rest-project,eng 
  - **usr**: `martin`, **pwd**: `martin`, **roles**: user,developer,rest-project,pm

**KIE Server**

- The KIE Server is installed on `patch-install-reproducer/bamoe/ks` 
- It has a port-offset of 100 
- Users configuration: 
  - **usr**: martin, **pwd**: martin, **roles**: rest-project,eng,kie-server
  - **usr**: karina, **pwd**: karina, **roles**:  rest-project,pm,kie-server
  
Key changes related to the behavior:
- Patch added to bamoe/bc/jboss-eap-7.4/standalone/deployments/business-central.war/WEB-INF/lib/
- uses `standalone-full.xml` by default
- System property on BC: `/system-property=jbpm.wb.querymode:add(value="STRICT")`
- Users & Roles settings on both EAPs 
- Groups permissions set on Business Central
- Project configuration (can be done on a server level as well): `required-roles`

Here are the configured settings: 

1. Spaces configured as follows:

    ![space-eng.png](docs%2Fspace-eng.png)
    ![space-pm.png](docs%2Fspace-pm.png)

2. Projects configured as follows:

    ![project-eng-required-roles.png](docs%2Fproject-eng-required-roles.png)
    ![project-pm-required-roles.png](docs%2Fproject-pm-required-roles.png)

3. Access in BC configured as follows:

    ![group-permissions-bc-eng.png](docs%2Fgroup-permissions-bc-eng.png)
    ![group-permissions-bc-pm.png](docs%2Fgroup-permissions-bc-pm.png)

4. Users configured as follows, on business central (obtained with `jboss-eap-7.4/bin/jboss-cli.sh` ):
    
    ```
    [standalone@localhost:9990 /] /subsystem=elytron/filesystem-realm=ApplicationRealm:read-identity(identity=martin)
    {
        "outcome" => "success",
        "result" => {
            "name" => "martin",
            "attributes" => {"role" => [
                "user",
                "developer",
                "rest-project",
                "eng"
            ]}
        }
    }
    [standalone@localhost:9990 /] /subsystem=elytron/filesystem-realm=ApplicationRealm:read-identity(identity=karina)
    {
        "outcome" => "success",
        "result" => {
            "name" => "karina",
            "attributes" => {"role" => [
                "user",
                "developer",
                "rest-project",
                "pm"
            ]}
        }
    }
    ```

    And on KIE-Server, as follows (obtained with `jboss-eap-7.4/bin/jboss-cli.sh --controller=127.0.0.1:10090` )
    
    ```
   
    [standalone@embedded /] /subsystem=elytron/filesystem-realm=ApplicationRealm:read-identity(identity=martin)
    {
        "outcome" => "success",
        "result" => {me="Access-Control-Allow-Credentials",header-value="true")
            "name" => "martin",-Control-Allow-Credentials",header-value="true")
            "attributes" => {"role" => [Allow-Credentials",header-value="true")
                "rest-project",
                "eng",
                "kie-server"
            ]}
        }
    }
    
    [standalone@embedded /] /subsystem=elytron/filesystem-realm=ApplicationRealm:read-identity(identity=karina)
    {
        "outcome" => "success",
        "result" => {
            "name" => "karina",
            "attributes" => {"role" => [
                "rest-project",
                "pm",
                "kie-server"
            ]}
        }
    }
    ```
----
Behavior: 

[patch-behavior.mov](docs%2Fpatch-behavior.mov)

