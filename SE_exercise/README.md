
<img src="./quali_torque_logo.png" width="60%">

# Technical Evaluation Exercise 

## Experience Torque Product

### overview
This exercise is designed to allows potential SE to gain expereince with Quali Torque SaaS product and demonstrate problem solving, integration and technical skills.

The main parts of this exercise include the followng tasks:

:white_check_mark: Explore and review Torque SaaS platform.

:white_check_mark: Review and understand Torque Blueprints and Environments.

:white_check_mark: Get familiar with Torque product and API documents.

:white_check_mark: discover an existing Terraform module, create a Blueprint and launch the Blueprint.

:white_check_mark: Automate the launch of the Blueprint by REST call with github actions.

:white_check_mark: Understand Quali Torque SaaS product value proposition.

## Task activities

Below is a list of activtes made to complete the execrsie and execute the task. Wach phse will include reference from the code modified, activities and the documents used to resolve and assist completing the task.

### Initiation and setup
The initiation phase includes discovery and import of the destination repository to Torque for creating the blueprints.
In this phase I used the **Asset Discovery** procedure describes in Qorque document:  

:owl: https://docs.qtorque.io/getting-started/Discover%20Your%20Assets 

The following activities were executed:

1) Login to Torque and revirew the menu options
2) Fork Quali Torge github source from: https://github.com/bhandley/BH_Torque_examples to my repository: https://github.com/shayrm/SE_Test_Torque
3) Review the `ssm.tf` file and understand the used resources and inputs.
4) In Torque SaaS use the **Repositories** option to integrate to my Github repository.
5) Allow discovery of my repository to Torque repository with required permissions.
6)  Review the ssm blueprint which was added to the Blueprint section.

### Blueprint modification.
The imported Terraform stor and create a new key value pair in AWS System Service Managment. 
The initiation phase and Blueprint creation basicly managed to enrich the original .tf file with additional options such as:
 
 * Duriation - environment timer.
 * Blueprint inputs - provided by the user
 * Tags - The user could add default tags for better metadata records.  
 * Use API or cli plugin when creating an environment with REST.
 * Rule base posicy - to enforce environment setup.

(below is the ssm blueprint yaml file for reference).

I used Torque document below to modify the Blueprint's inputs and add AWS credencial

:owl: https://docs.qtorque.io/getting-started/Getting%20starting%20with%20terraform

:owl: https://docs.qtorque.io/getting-started/Getting%20starting%20with%20terraform#aws-authentication

At the end of the process the following ssm yaml file was created:

```yaml
spec_version: 2
description: Torque auto generated blueprint
# blueprint inputs can be provided by the user, API or CI plugin when creating an environment from this blueprint.
inputs:
  aws_region:
    type: string
    default: us-east-1
  name:
    type: string
    default: test_name
  value:
    type: string
    default: test_value
  agent:
    type: agent
  AWS_ACCESS_KEY:
    type: string
  AWS_SECRET_KEY:
    type: string
# blueprint outputs define which data that was generated during environment provisioning will be returned to the user, API or CI.
outputs:
  ssm_ssm_parameter_name:
    value: '{{ .grains.ssm.outputs.ssm_parameter_name }}'
    quick: true
  ssm_ssm_parameter_value:
    value: '{{ .grains.ssm.outputs.ssm_parameter_value }}'
    quick: true
grains:
  ssm:
    kind: terraform
    spec:
      source:
        store: SE_Test_Torque
        path: terraform/ssm
      agent:
      # The Torque agent that will be used to provision the environment.
        name: '{{ .inputs.agent }}'
        # A service account annotated with a role ARN with permissions to run the asset
        # service-account: <service-account-name>
        # Will override the default value for Runners isolation
        # isolated: <boolean>
      inputs:
      - aws_region: '{{ .inputs.aws_region }}'
      - name: '{{ .inputs.name }}'
      - value: '{{ .inputs.value }}'
      # The environment variables declared in this section will be available during the grain deployment as well as the grain destroy phase
      # env-vars:
      # - VAR_NAME: var value
      env-vars: 
        - AWS_ACCESS_KEY: '{{ .inputs.AWS_ACCESS_KEY }}'
        - AWS_SECRET_KEY: '{{ .inputs.AWS_SECRET_KEY }}'
      outputs:
      - ssm_parameter_name
      - ssm_parameter_value
    # The terraform version that will be used to deploy the module
    tf-version: 1.5.5

```

> [!WARNING] 
> It would be good if the `AWS_ACCESS_KEY` and `AWS_SECRET_KEY` were masked and not presented as a clear text in the environment logs.
> 

### Launch Environment 
At first I launch the environment from the GUI.
This phase alow me to make sure the Blueprint is correct and environment could be executed to preduce the required IaaC.

Below is an axample of manual execution:

![ssm blueprint](./ssm_bp_1.png)

![ssm blueprint review](./ssm_bp_2.png)

### Automation and REST calls

Now after confirming manual launch of the environment, I moved on to the remote execution of the environment with REST API call.
For that I use Torque API document and study how the API could be use for executing new environment from blueprint.

:owl: https://portal.qtorque.io/api_reference/#/paths/api-spaces-space_name--environments/post

To generate Authorization token I had to go to the Integrations page and click the Connect button on **GitHub Action** instruction.
In the Configure section, I could click on “Generate New Token” and copy the displayed token value. 

![Generate Token](./token.png)

At first, I tried to list the existing environment `Gets environment details`

![List Envorinment](./list_env.png)


Confirming the Token validation, I could move on and selet the POST `/api/spaces/{space_name}/environments`

Next step was to import the API reference from [Torque API Reference](https://portal.qtorque.io/api_reference/#/) to Postman.
In Postman I could define environment paramerts which could help later on with the Github Action yaml file.

Defind the relevant Global Environment and Pre-request-script to successfuly define the POST schema.

![postman new env](./Postman_new_env_1.png)

![postman pre-request](./Postman_pre-request.png)

![postman vairlables](./Postman_env_params.png)


> [!IMPORTANT]  
> During my attempts to generate the correct POST request I had to figure out the syntext of the `duriation` field.
> I had to manualy lunch again the `ssm` blueprint and use the browser Dev tools to track down the post request and verify the correct sintext of the `duriation` field.
>
> ![duriation field](./debug_duriation.png) 

Now that I could run the API request from remote I could create the structure of the Github action workflow.

### Github Action workflow

To run the workflow I choose to use manual `workflow_dispatch` following the [Manually running a workflow](https://docs.github.com/en/actions/using-workflows/manually-running-a-workflow) instructions.

I used github **Actions secrets and variables** to create the relevant secreats (AWS keys and Torque token) and variables.

To run the request I chose to use Python script with the `request` command.

The github action could be found file could be found in this repository at [start_ssm_env_py.yml](../.github/workflows/start_ssm_env_py.yml)

Below is an example of successful Github action workflow and the **event id** created following the POST request.

![workflow run](./github_action_success.png)

On the target AWS account we got the following results:

![aws ssm results](./aws_ssm_results.png)


## Conclusions

In conclusion, this technical evaluation exercise provided a comprehensive opportunity to gain hands-on experience with Quali Torque's SaaS product and demonstrate various technical skills, including problem-solving, integration, and automation.

The exercise resulted in the successful remote launch of the environment, as demonstrated by a GitHub Action workflow. This event ID confirmed the execution of the POST request, and corresponding results were observed in Torque environment page in the target AWS account. The environment was terminated at the duriation timer experation.

The Quali Torque SaaS solution offers a range of business benefits that can significantly impact an organization's operations and outcomes. These benefits extend beyond technical capabilities and are instrumental in achieving business goals and objectives. Here are some key aspects of the business value that Torque brings to the table:

1. Improved Efficiency and Productivity
2. Cost Reduction
3. Enhanced Collaboration
4. Scalability and Flexibility
5. Risk Mitigation (manual processes and human error)
7. Compliance and Reporting

And probably there are many more...


