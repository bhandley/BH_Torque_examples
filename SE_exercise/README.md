# Technical Evaluation Exercise 
<img src="./quali_torque_logo.png" width="30%">

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
4) In Torque SaaS allow discovery of my repository to Torque repository with required permissions.
5)  Review the ssm blueprint which was added to the Blueprint section.

### Blueprint modification.
The initiation phase and Blueprint creation basicly managed to use the original Terraform file and enrich it with additional options such as blueprint inputs which can be provided by the user, API or CI plugin when creating an environment from this blueprint.
(below is the ssm blueprint yaml file for reference).

I used Torque document below to modify the Blueprint's inputs and add AWS credencial


:owl: https://docs.qtorque.io/getting-started/Getting%20starting%20with%20terraform

:owl: https://docs.qtorque.io/getting-started/Getting%20starting%20with%20terraform#aws-authentication

At the end of the process the following ssm yaml file was created:

> [!WARNING] 
> It would be good if the `AWS_ACCESS_KEY` and `AWS_SECRET_KEY` were masked and not presented as a clear text in the environment logs


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