package torque.environment

import future.keywords.if

# This policy enforces rules for how many vCPUs a user is allowed to request when deploying vmware VMs
# It takes two numbers as arguments (in the data object):
#   1. env_max_vcpus : the highest number of vcpus the user is allowed to request. Entries above this value will be denied
#   2. env_needs_approval_vcpus : the number of vcpus above which a request requires approval
#
# An example of a data object for this policy looks like this:
# {
#   "env_max_vcpus": 16,
#   "env_needs_approval_vcpus": 5
# }
#

result := { "decision": "Denied", "reason": "environment must have a value for vcpus" } if {
    not input.inputs.vcpus
}

result := {"decision": "Denied", "reason": "max_vcpus and needs_approval_vcpus have to be numbers."} if {
	data.env_max_vcpus
	not is_number(data.env_max_vcpus)
	data.env_needs_approval_vcpus
	not is_number(data.env_needs_approval_vcpus)
}

#result = {"decision": "Denied", "reason": "requested number of vcpus exceeds maximum of"} if {
result = {"decision": "Denied", "reason": sprintf("requested number of vcpus exceeds maximum of %d", [data.env_max_vcpus])} if {
    is_number(data.env_max_vcpus)
	input.inputs.vcpus > data.env_max_vcpus
}

result = {"decision": "Manual", "reason": "this number of vcpus requires approval"} if {
	is_number(data.env_max_vcpus)
	is_number(data.env_needs_approval_vcpus)
	data.env_max_vcpus >= input.inputs.vcpus
	data.env_needs_approval_vcpus <= input.inputs.vcpus
}

result = {"decision": "Approved"} if {
    is_number(data.env_max_vcpus)
	is_number(data.env_needs_approval_vcpus)
	data.env_max_vcpus >= input.inputs.vcpus
	data.env_needs_approval_vcpus > input.inputs.vcpus
}